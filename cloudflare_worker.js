export default {
  async fetch(request, env) {
    // Adicionar suporte a CORS para preflights
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type"
        }
      });
    }

    const url = new URL(request.url);
    const path = url.pathname;

    // Rota para interpretação de sonhos
    if (path === "/" && request.method === "POST") {
      return await interpretarSonho(request, env);
    }
    
    // Rotas para gerenciamento de sonhos
    if (path === "/sonhos" && request.method === "GET") {
      return await listarSonhos(env);
    }
    
    if (path === "/sonhos" && request.method === "POST") {
      return await salvarSonho(request, env);
    }
    
    if (path.startsWith("/sonhos/") && request.method === "GET") {
      const id = path.split("/")[2];
      return await obterSonho(id, env);
    }

    return new Response("Não encontrado", { status: 404 });
  }
};

// Função para interpretar sonhos usando a API Gemini
async function interpretarSonho(request, env) {
  try {
    // Obter os dados da requisição
    const { descricaoSonho } = await request.json();
    
    if (!descricaoSonho) {
      return new Response(JSON.stringify({
        interpretacao: "Seu sonho parece vazio como uma sala escura sem cortinas."
      }), {
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
    const response = await fetch("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent", {
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
          temperature: 0.9,
          maxOutputTokens: 800,
          topK: 40,
          topP: 0.95
        }
      })
    });

    const data = await response.json();
    
    // Extrair a interpretação da resposta da API Gemini
    let interpretacao = "As cortinas vermelhas se fecharam temporariamente.";
    
    if (data.candidates && data.candidates[0] && data.candidates[0].content) {
      interpretacao = data.candidates[0].content.parts[0].text;
    }

    // Retornar a interpretação
    return new Response(JSON.stringify({ interpretacao }), {
      headers: { 
        "Content-Type": "application/json", 
        "Access-Control-Allow-Origin": "*" 
      }
    });
  } catch (error) {
    console.error("Erro:", error);
    
    return new Response(JSON.stringify({
      interpretacao: "As cortinas vermelhas se fecharam temporariamente. Como em um salão enigmático de Twin Peaks, sua interpretação existe, mas está momentaneamente além do alcance."
    }), {
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  }
}

// Função para listar todos os sonhos
async function listarSonhos(env) {
  try {
    const listaIds = await env.SONHOS_KV.list();
    const sonhos = [];
    
    for (const key of listaIds.keys) {
      const sonhoJson = await env.SONHOS_KV.get(key.name);
      if (sonhoJson) {
        sonhos.push(JSON.parse(sonhoJson));
      }
    }
    
    // Ordenar por data de criação (mais recente primeiro)
    sonhos.sort((a, b) => new Date(b.dataCriacao) - new Date(a.dataCriacao));
    
    return new Response(JSON.stringify(sonhos), {
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  } catch (error) {
    console.error("Erro ao listar sonhos:", error);
    return new Response(JSON.stringify([]), {
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  }
}

// Função para salvar um novo sonho
async function salvarSonho(request, env) {
  try {
    const sonho = await request.json();
    
    // Validar dados
    if (!sonho.titulo || !sonho.descricao || !sonho.interpretacao) {
      return new Response(JSON.stringify({ erro: "Dados incompletos" }), {
        status: 400,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      });
    }
    
    // Gerar ID único
    const id = crypto.randomUUID();
    
    // Adicionar ID ao sonho
    const sonhoCompleto = {
      id,
      titulo: sonho.titulo,
      descricao: sonho.descricao,
      interpretacao: sonho.interpretacao,
      dataCriacao: sonho.dataCriacao || new Date().toISOString()
    };
    
    // Salvar no KV
    await env.SONHOS_KV.put(id, JSON.stringify(sonhoCompleto));
    
    return new Response(JSON.stringify(sonhoCompleto), {
      status: 201,
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  } catch (error) {
    console.error("Erro ao salvar sonho:", error);
    return new Response(JSON.stringify({ erro: "Erro ao salvar sonho" }), {
      status: 500,
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  }
}

// Função para obter um sonho específico
async function obterSonho(id, env) {
  try {
    const sonhoJson = await env.SONHOS_KV.get(id);
    
    if (!sonhoJson) {
      return new Response(JSON.stringify({ erro: "Sonho não encontrado" }), {
        status: 404,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      });
    }
    
    return new Response(sonhoJson, {
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  } catch (error) {
    console.error("Erro ao obter sonho:", error);
    return new Response(JSON.stringify({ erro: "Erro ao obter sonho" }), {
      status: 500,
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  }
} 