// Extrae clientes de staging (con campos, lotes y geometria) a un JSON local.
// Ver docs/04-copiar-datos-staging-a-local.md para el procedimiento completo.
//
// Uso:
//   1. Editar CLIENTE_NOMBRES abajo con los clientes que queres copiar.
//   2. Conseguir el token de sesion (ver el doc) y guardarlo en
//      scripts/staging-copy/staging_token.txt (un solo string, sin comillas).
//   3. node extract_staging.js
//
// Genera scripts/staging-copy/staging_export.json (gitignored).

const fs = require('fs');
const path = require('path');

const CLIENTE_NOMBRES = [
  'Aumaq',
  'Aumaq - Cereales25',
  'El Criterio',
  'HJ Navas',
  'Scarponi-Peloso',
  'Scarponi-Peloso - Cereales 25',
];
const STAGING_API = 'https://staging-api.farmiasolutions.com';

const tokenPath = path.join(__dirname, 'staging_token.txt');
if (!fs.existsSync(tokenPath)) {
  console.error(
    'Falta ' + tokenPath + ' con el token de sesion de staging. Ver el doc.',
  );
  process.exit(1);
}
const token = fs.readFileSync(tokenPath, 'utf8').trim();
const auth = { Authorization: 'Bearer ' + token };

async function getJson(p) {
  const res = await fetch(STAGING_API + p, { headers: auth });
  if (!res.ok) throw new Error('GET ' + p + ' -> ' + res.status);
  return res.json();
}

async function buildClienteExport(clienteId) {
  const cliente = await getJson('/clientes/' + clienteId);
  const campos = [];
  for (const c of cliente.campos || []) {
    const lotes = await getJson('/campos/' + c.id + '/lotes');
    campos.push({
      nombre: c.nombre,
      ubicacion: c.ubicacion || null,
      lotes: lotes.map((l) => ({
        nombre: l.nombre,
        superficieHa: l.superficieHa,
        notas: l.notas || null,
        geometryGeojson: l.geometryGeojson,
      })),
    });
  }
  return { nombre: cliente.nombre, campos };
}

(async () => {
  const todos = await getJson('/clientes');
  const resultado = {};

  for (const nombre of CLIENTE_NOMBRES) {
    const match = todos.find((c) => c.nombre === nombre);
    if (!match) {
      console.warn('No encontrado en staging, se omite: ' + nombre);
      continue;
    }
    console.log('Leyendo ' + nombre + '...');
    const clienteExport = await buildClienteExport(match.id);
    const key = nombre.replace(/[^a-zA-Z0-9]+/g, '_');
    resultado[key] = clienteExport;
    console.log(
      '  campos: ' +
        clienteExport.campos.map((c) => c.nombre + '=' + c.lotes.length).join(', '),
    );
  }

  const outPath = path.join(__dirname, 'staging_export.json');
  fs.writeFileSync(outPath, JSON.stringify(resultado));
  console.log('Guardado en ' + outPath);
})().catch((e) => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
