export default function Home() {
  return (
    <main style={{ fontFamily: 'system-ui', maxWidth: 960, margin: '0 auto', padding: 24 }}>
      <h1 style={{ color: '#0066CC' }}>Tienda Cuba</h1>
      <p>Tienda web en construcción. Usa la app Android para la mejor experiencia.</p>
      <p>Backend API: <code>/api</code></p>
      <ul>
        <li>Transfermóvil BANDEC (CUP / MLC) – aprobación manual</li>
        <li>TRX y USDT TRC20 – confirmación automática</li>
      </ul>
    </main>
  );
}
