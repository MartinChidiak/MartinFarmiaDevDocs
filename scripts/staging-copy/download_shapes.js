// Descarga el limite de cada lote de staging como shapefile (.zip) y/o KML.
// Ver docs/04-copiar-datos-staging-a-local.md.
//
// Usa GET /lotes/:id/geometry/export?format=shp|kml, que devuelve una URL
// prefirmada de S3; despues baja el archivo desde ahi. El nombre de archivo lo
// define el propio API: limite_lote_{cliente}_{campo}_{lote}.{zip|kml}
//
// Idempotente: saltea los archivos que ya existen en OUT_DIR.
//
// Uso:
//   1. Poner el token de staging en staging_token.txt (ver el doc).
//   2. Ajustar OUT_DIR / FORMATOS / CLIENTE_NOMBRES si hace falta.
//   3. node download_shapes.js

const fs = require('fs');
const path = require('path');

const OUT_DIR = 'C:\\Users\\marti\\OneDrive\\Farmia\\El Criterio\\Shapes';
const FORMATOS = ['shp', 'kml']; // 'shp' baja un .zip de shapefile; 'kml' un .kml
const CLIENTE_NOMBRES = null; // null = todos los clientes; o un array de nombres
const STAGING_API = 'https://staging-api.farmiasolutions.com';
const PAUSA_MS = 150; // pausa entre exportaciones, para no saturar el worker

const token = fs
  .readFileSync(path.join(__dirname, 'staging_token.txt'), 'utf8')
  .trim();
const auth = { Authorization: 'Bearer ' + token };

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function getJson(p) {
  const res = await fetch(STAGING_API + p, { headers: auth });
  if (!res.ok) throw new Error('GET ' + p + ' -> ' + res.status);
  return res.json();
}

async function listarLotes() {
  const clientes = await getJson('/clientes');
  const filtrados = CLIENTE_NOMBRES
    ? clientes.filter((c) => CLIENTE_NOMBRES.includes(c.nombre))
    : clientes;

  const salida = [];
  for (const cliente of filtrados) {
    const detalle = await getJson('/clientes/' + cliente.id);
    for (const campo of detalle.campos || []) {
      const lotes = await getJson('/campos/' + campo.id + '/lotes');
      for (const lote of lotes) {
        salida.push({
          id: lote.id,
          cliente: cliente.nombre,
          campo: campo.nombre,
          lote: lote.nombre,
          tieneGeom: !!lote.geometryGeojson,
        });
      }
    }
  }
  return salida;
}

async function descargarUno(lote, formato, stats) {
  const meta = await getJson(
    `/lotes/${lote.id}/geometry/export?format=${formato}`,
  );
  const destino = path.join(OUT_DIR, meta.filename);

  if (fs.existsSync(destino)) {
    stats.salteados++;
    return;
  }

  const res = await fetch(meta.downloadUrl);
  if (!res.ok) throw new Error('download -> ' + res.status);
  const buf = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(destino, buf);
  stats.bajados++;
  stats.bytes += buf.length;
}

(async () => {
  fs.mkdirSync(OUT_DIR, { recursive: true });

  console.log('Listando lotes de staging...');
  const lotes = await listarLotes();
  const conGeom = lotes.filter((l) => l.tieneGeom);
  console.log(
    `${lotes.length} lotes (${conGeom.length} con geometria exportable), ` +
      `formatos: ${FORMATOS.join(', ')}`,
  );

  const stats = { bajados: 0, salteados: 0, errores: 0, bytes: 0 };
  let i = 0;

  for (const lote of conGeom) {
    i++;
    for (const formato of FORMATOS) {
      try {
        await descargarUno(lote, formato, stats);
      } catch (e) {
        stats.errores++;
        console.warn(
          `  ERROR ${lote.cliente}/${lote.campo}/${lote.lote} [${formato}]: ${e.message}`,
        );
      }
      await sleep(PAUSA_MS);
    }
    if (i % 25 === 0 || i === conGeom.length) {
      console.log(
        `  ${i}/${conGeom.length} lotes | bajados ${stats.bajados} | ` +
          `salteados ${stats.salteados} | errores ${stats.errores}`,
      );
    }
  }

  console.log('\nListo.');
  console.log(
    `bajados: ${stats.bajados} | ya existian: ${stats.salteados} | ` +
      `errores: ${stats.errores} | total: ${(stats.bytes / 1024 / 1024).toFixed(1)} MB`,
  );
  console.log('Destino: ' + OUT_DIR);
})().catch((e) => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
