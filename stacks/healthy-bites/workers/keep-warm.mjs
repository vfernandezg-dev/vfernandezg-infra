// Mantiene caliente una instancia de la API de Healthy Bites: Vercel apaga las instancias tras 5 minutos sin
// tráfico y arrancar de nuevo cuesta unos segundos. Cada 4 minutos llama a la sonda de vida, que no consulta la base
// de datos (Neon puede seguir suspendiéndose). Sin manejador fetch: el Worker no responde a peticiones.
export default {
  async scheduled(_controller, env) {
    const response = await fetch(env.PING_URL, {
      headers: { 'user-agent': 'healthy-bites-keep-warm' },
    });
    if (!response.ok) {
      console.error(`${env.PING_URL} respondió ${response.status}`);
    }
  },
};
