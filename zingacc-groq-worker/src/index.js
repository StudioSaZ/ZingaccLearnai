export default {
  async fetch(request, env, ctx) {
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
      "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Requested-With",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    let promptText = "";

    try {
      if (request.method === "POST") {
        const body = await request.json();
        const messages = body?.messages;
        promptText = body?.promptText || (Array.isArray(messages) ? messages[messages.length - 1]?.content : null);
      } else if (request.method === "GET") {
        const url = new URL(request.url);
        promptText = url.searchParams.get("prompt");
      }
    } catch (e) {
      promptText = "";
    }

    // කිසිදු ප්‍රශ්නයක් ලැබී නැත්නම් සහ GET රික්වෙස්ට් එකක් නම් ස්ටෑටික් ඇසට්ස් (Flutter Web) වෙත බාර දෙනු ලැබේ
    if (!promptText && request.method === "GET") {
      return env.ASSETS.fetch(request);
    }

    if (!promptText || typeof promptText !== "string" || promptText.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Invalid prompt" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (!env.GROQ_API_KEY) {
      return new Response(JSON.stringify({ error: "Server configuration error" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    try {
      const groqResponse = await fetch(
        "https://api.groq.com/openai/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${env.GROQ_API_KEY}`,
          },
          body: JSON.stringify({
            model: "openai/gpt-oss-120b",
            messages: [
              {
                role: "system",
                content:
                  "You are an expert Sri Lankan school teacher helping O/L and A/L students in Science, Mathematics, and Religion. Always provide answers in accurate Sinhala using proper local educational terminology."
              },
              {
                role: "user",
                content: promptText
              }
            ]
          })
        }
      );

      if (!groqResponse.ok) {
        const errText = await groqResponse.text();
        console.error("Groq status:", groqResponse.status, errText);
        return new Response(JSON.stringify({ error: "AI service temporarily unavailable", details: errText }), {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }

      const data = await groqResponse.json();
      const answer = data.choices?.[0]?.message?.content;

      return new Response(JSON.stringify({
        choices: [
          {
            message: {
              content: answer ? answer.trim() : "පිළිතුරක් ලබා ගත නොහැක."
            }
          }
        ],
        text: answer ? answer.trim() : "පිළිතුරක් ලබා ගත නොහැක."
      }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });

    } catch (error) {
      console.error("Worker error:", error.message);
      return new Response(JSON.stringify({ error: "AI request failed", message: error.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }
  }
};
