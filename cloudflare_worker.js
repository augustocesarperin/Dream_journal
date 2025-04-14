export default {
  async fetch(request, env) {
    // Adicionar suporte a CORS para preflights
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type"
        }
      });
    }

    const url = new URL(request.url);
    const path = url.pathname;

    // Rota ÚNICA: interpretação de sonhos
    if (path === "/" && request.method === "POST") {
      return await interpretarSonho(request, env);
    }
    
    // Se não for POST / ou OPTIONS, retorna 404
    return new Response("Endpoint não encontrado ou método inválido.", {
      status: 404,
      headers: {
        "Access-Control-Allow-Origin": "*"
      }
    });
  }
};

// Função para interpretar sonhos usando a API Gemini
async function interpretarSonho(request, env) {
  try {
    // Obter os dados da requisição
    const { descricaoSonho } = await request.json();
    
    if (!descricaoSonho || typeof descricaoSonho !== 'string' || descricaoSonho.trim().length === 0) {
      return new Response(JSON.stringify({
        interpretacao: "A descrição do sonho está vazia ou inválida. Como um filme sem projetor, não há nada para interpretar."
      }), {
        status: 400,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      });
    }

    // Construir o prompt no estilo David Lynch
    const prompt = `
    Você é um intérprete de sonhos no estilo surrealista e enigmático de David Lynch. 

    Crie uma interpretação que seja:
    - Misteriosa e ambígua, deixando espaço para múltiplas interpretações
    - Com metáforas visuais cinematográficas e inquietantes
    - Usando linguagem poética e evocativa
    - Mencionando elementos como cortinas vermelhas, salas escuras, luzes piscando
    - Com um tom ligeiramente perturbador que sugere que há mais além da superfície
    - Fazendo referências sutis a símbolos recorrentes nos trabalhos de Lynch
    - Combinando o mundano com o surreal de forma inesperada

    Limite sua resposta a 3-4 parágrafos curtos.

    Interprete este sonho de forma lynchiana: 
    ${descricaoSonho}
    `;

    // Fazer requisição para a API Gemini
    const geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";
    const apiKey = env.GEMINI_API_KEY;

    if (!apiKey) {
      console.error("Erro: GEMINI_API_KEY não está configurada no ambiente do Worker.");
      return new Response(JSON.stringify({
        interpretacao: "Erro de configuração no servidor. A chave para o mundo dos sonhos não foi encontrada."
      }), {
        status: 500,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      });
    }

    const geminiResponse = await fetch(geminiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey
      },
      body: JSON.stringify({
        contents: [{
          parts: [{
            text: prompt
          }]
        }],
        generationConfig: {
          temperature: 0.9,
          maxOutputTokens: 800,
          topK: 40,
          topP: 0.95
        }
      })
    });

    if (!geminiResponse.ok) {
        const errorBody = await geminiResponse.text();
        console.error(`Erro da API Gemini: ${geminiResponse.status} ${geminiResponse.statusText}, Corpo: ${errorBody}`);
        return new Response(JSON.stringify({
            interpretacao: `As cortinas vermelhas tremulam com um erro (${geminiResponse.status}). Tente novamente mais tarde.`
        }), {
            status: 502,
            headers: { 
                "Content-Type": "application/json", 
                "Access-Control-Allow-Origin": "*" 
            }
        });
    }

    const data = await geminiResponse.json();
    
    // Extrair a interpretação da resposta da API Gemini
    let interpretacao = "As cortinas vermelhas se fecharam temporariamente. Nenhum som veio do palco.";
    
    if (data.candidates && data.candidates[0] && data.candidates[0].content && data.candidates[0].content.parts && data.candidates[0].content.parts[0].text) {
      interpretacao = data.candidates[0].content.parts[0].text.trim();
    } else {
      console.error("Resposta inesperada da API Gemini:", JSON.stringify(data));
    }

    // Retornar a interpretação
    return new Response(JSON.stringify({ interpretacao }), {
      headers: { 
        "Content-Type": "application/json", 
        "Access-Control-Allow-Origin": "*" 
      }
    });

  } catch (error) {
    console.error("Erro inesperado na função interpretarSonho:", error);
    return new Response(JSON.stringify({
      interpretacao: "As cortinas vermelhas se fecharam abruptamente. Como em um salão enigmático, sua interpretação existe, mas está momentaneamente além do alcance."
    }), {
      status: 500,
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  }
} 