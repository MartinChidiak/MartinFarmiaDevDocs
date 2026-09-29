// Importa el JSON generado por extract_staging.js a un stack local de FarmIA.
// Ver docs/04-copiar-datos-staging-a-local.md para el procedimiento completo.
//
// Idempotente: se puede correr varias veces. Matchea cliente/campo/lote por
// nombre; si existe, actualiza superficie/notas/geometria; si no, lo crea.
// Nunca borra lotes locales que no aparezcan en el export.
//
// Uso:
//   1. Editar LOCAL_API y DEV_EMAIL abajo segun el stack de destino.
//   2. node import_local.js

const fs = require('fs');
const path = require('path');

const LOCAL_API = 'http://127.0.0.1:3203'; // API del stack local/worktree destino
const DEV_EMAIL = 'elcriterio@farmiasolutions.com'; // perfil dev dueno de los datos

const auth = { Authorization: 'Bearer dev-token::' + DEV_EMAIL };

const data = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'staging_export.json'), 'utf8'),
);

async function getJson(p) {
  const res = await fetch(LOCAL_API + p, { headers: auth });
  if (!res.ok) throw new Error('GET ' + p + ' -> ' + res.status + ' ' + (await res.text()));
  return res.json();
}

async function postJson(p, body) {
  const res = await fetch(LOCAL_API + p, {
    method: 'POST',
    headers: { ...auth, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error('POST ' + p + ' -> ' + res.status + ' ' + (await res.text()));
  return res.json();
}

async function patchJson(p, body) {
  const res = await fetch(LOCAL_API + p, {
    method: 'PATCH',
    headers: { ...auth, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error('PATCH ' + p + ' -> ' + res.status + ' ' + (await res.text()));
  return res.json();
}

async function ensureCliente(nombre) {
  const existentes = await getJson('/clientes');
  const found = existentes.find((c) => c.nombre === nombre);
  if (found) return found.id;
  const created = await postJson('/clientes', { nombre });
  return created.id;
}

async function ensureCampo(clienteId, nombreCampo, ubicacion) {
  const existentes = await getJson(`/clientes/${clienteId}/campos`);
  const found = existentes.find((c) => c.nombre === nombreCampo);
  if (found) return found.id;
  const created = await postJson(`/clientes/${clienteId}/campos`, {
    nombre: nombreCampo,
    ubicacion: ubicacion || undefined,
  });
  return created.id;
}

async function ensureLoteWithGeometry(campoId, lote, stats) {
  const existentes = await getJson(`/campos/${campoId}/lotes`);
  const found = existentes.find((l) => l.nombre === lote.nombre);
  let loteId;
  if (found) {
    loteId = found.id;
    await patchJson(`/lotes/${loteId}`, {
      superficieHa: lote.superficieHa,
      notas: lote.notas || undefined,
    });
    stats.updated++;
  } else {
    const created = await postJson(`/campos/${campoId}/lotes`, {
      nombre: lote.nombre,
      superficieHa: lote.superficieHa,
      notas: lote.notas || undefined,
    });
    loteId = created.id;
    stats.created++;
  }
  if (lote.geometryGeojson) {
    await patchJson(`/lotes/${loteId}/geometry`, {
      geometryGeojson: lote.geometryGeojson,
    });
  }
}

(async () => {
  const stats = { created: 0, updated: 0 };

  for (const key of Object.keys(data)) {
    const clienteExport = data[key];
    console.log('Importando ' + clienteExport.nombre + '...');
    const clienteId = await ensureCliente(clienteExport.nombre);
    for (const campo of clienteExport.campos) {
      const campoId = await ensureCampo(clienteId, campo.nombre, campo.ubicacion);
      for (const lote of campo.lotes) {
        await ensureLoteWithGeometry(campoId, lote, stats);
      }
      console.log(`  campo "${campo.nombre}" ok (${campo.lotes.length} lotes)`);
    }
  }

  console.log('Listo. lotes creados:', stats.created, '| lotes actualizados:', stats.updated);
})().catch((e) => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
