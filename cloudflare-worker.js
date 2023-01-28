export default {
  async fetch(request, env) {
    // Suporte a CORS para preflights
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type"
        }
      });
    }

    if (request.method !== "POST") {
      return new Response("Método não permitido", { status: 405 });
    }

    try {
      const { descricaoSonho } = await request.json();
      console.log("Descrição do sonho recebida");
      
      if (!descricaoSonho) {
        return new Response(JSON.stringify({
          interpretacao: "Seu sonho parece vazio como uma sala escura sem cortinas."
        }), {
          headers: { 
            "Content-Type": "application/json; charset=utf-8",
            "Access-Control-Allow-Origin": "*"
          }
        });
      }

      const prompt = `
      Você é um intérprete de sonhos sensível e perspicaz, com conhecimento em psicanálise mas que prioriza uma linguagem acessível e reflexões significativas sobre a experiência humana.
      
      Analise o seguinte sonho com sensibilidade e profundidade:
      
      "${descricaoSonho}"
      
      Sua interpretação deve:
      
      1. Identificar 2-3 imagens ou elementos marcantes do sonho e explorar seus possíveis significados de forma acessível e reflexiva.
      
      2. Sugerir como esses elementos podem se conectar com a vida emocional, desejos ou inquietações do sonhador, evitando jargão técnico.
      
      3. Oferecer uma perspectiva que ilumine o significado pessoal do sonho, usando metáforas e linguagem poética quando apropriado.
      
      4. Conectar o sonho com temas universais da experiência humana (como busca de sentido, transformação, relacionamentos, medos).
      
      5. Concluir com uma reflexão que convide o sonhador a contemplar como este sonho pode enriquecer seu autoconhecimento.
      
      Formato:
      - Use linguagem acessível, evocativa e reflexiva, como uma conversa íntima e significativa
      - Evite completamente jargão técnico e termos psicanalíticos específicos
      - Estruture em 2-3 parágrafos fluidos que convidem à reflexão
      - Inclua uma metáfora ou imagem poética que amplie a compreensão do sonho
      
      Importante: Priorize a clareza e a profundidade humana sobre a teoria. Como escreveu Rilke, "viva as perguntas agora" - ofereça uma interpretação que abra possibilidades de significado em vez de fechá-las com explicações técnicas.
      `;

      const response = await fetch("https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": env.GEMINI_API_KEY
        },
        body: JSON.stringify({
          contents: [{
            parts: [{
              text: prompt
            }]
          }],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 400,
            topK: 40,
            topP: 0.95
          }
        })
      });
      
      const data = await response.json();
      
      if (data.error) {
        console.error("Erro da API Gemini:", data.error);
        return new Response(JSON.stringify({
          interpretacao: "Não foi possível analisar seu sonho neste momento. Por favor, tente novamente mais tarde."
        }), {
          headers: { 
            "Content-Type": "application/json; charset=utf-8",
            "Access-Control-Allow-Origin": "*"
          }
        });
      }
      
      let interpretacao = "Não foi possível analisar seu sonho neste momento.";
      
      if (data.candidates && data.candidates[0] && data.candidates[0].content) {
        interpretacao = data.candidates[0].content.parts[0].text;
        
        if (interpretacao.length > 1200) {
          const lastSentenceEnd = Math.max(
            interpretacao.lastIndexOf('. ', 1200),
            interpretacao.lastIndexOf('? ', 1200),
            interpretacao.lastIndexOf('! ', 1200)
          );
          
          if (lastSentenceEnd > 0) {
            interpretacao = interpretacao.substring(0, lastSentenceEnd + 1);
          } else {
            interpretacao = interpretacao.substring(0, 1197) + "...";
          }
        }
        
        interpretacao = interpretacao
          .replace(/\n\n/g, "\n")
          .replace(/^\s*[\"\']|[\"\']\s*$/g, "")
          .trim();
      }

      return new Response(JSON.stringify({ interpretacao }), {
        headers: { 
          "Content-Type": "application/json; charset=utf-8", 
          "Access-Control-Allow-Origin": "*"
        }
      });
    } catch (error) {
      console.error("Erro:", error);
      
      return new Response(JSON.stringify({
        interpretacao: "Não foi possível processar sua solicitação. O inconsciente coletivo parece estar temporariamente inacessível."
      }), {
        headers: { 
          "Content-Type": "application/json; charset=utf-8",
          "Access-Control-Allow-Origin": "*"
        }
      });
    }
  }
}; 