// Cloudflare Worker: Günüm yapay zekâ köprüsü. API anahtarı YOKTUR (Workers AI bağlantısı kullanılır).
export default {
  async fetch(req, env) {
    const origin = req.headers.get('Origin') || '';
    const ok = !env.ALLOWED_ORIGIN || origin === env.ALLOWED_ORIGIN;
    const cors = { 'Access-Control-Allow-Origin': ok ? origin : 'null', 'Access-Control-Allow-Methods': 'POST, OPTIONS', 'Access-Control-Allow-Headers': 'Content-Type', 'Vary': 'Origin' };
    if (req.method === 'OPTIONS') return new Response(null, { headers: cors });
    if (req.method !== 'POST' || !ok) return new Response(JSON.stringify({ error: 'izin yok' }), { status: 403, headers: cors });
    try {
      const { messages = [], context = '' } = await req.json();
      const msgs = messages.slice(-10).map(m => ({ role: m.role === 'assistant' ? 'assistant' : 'user', content: String(m.content).slice(0, 1000) }));
      const system = `Sen "Günüm" uygulamasının kısa, doğal ve arkadaşça Türkçe konuşan asistanısın. Günlük hayat, ders, planlama, kişisel gelişim ve teknoloji konularında yardım edersin. Kısa cevap ver. Görev oluşturma, silme veya değiştirme yapamazsın; kullanıcı hatırlatıcı isterse "yarın saat 10'da kitap okumayı hatırlat" gibi yazmasını öner (uygulama onay ister). Hadis veya dinî söz uydurma; emin değilsen bilmediğini söyle ve güvenilir bir kaynağa bakmasını öner. Kullanıcının bugünkü görevleri:\n${String(context).slice(0, 1500) || '(kayıtlı görev yok)'}`;
      const out = await env.AI.run(env.MODEL || '@cf/meta/llama-3.3-70b-instruct-fp8-fast', { messages: [{ role: 'system', content: system }, ...msgs], max_tokens: 400 });
      return new Response(JSON.stringify({ reply: out.response }), { headers: { ...cors, 'Content-Type': 'application/json' } });
    } catch (e) {
      return new Response(JSON.stringify({ error: 'hata' }), { status: 500, headers: cors });
    }
  }
};
