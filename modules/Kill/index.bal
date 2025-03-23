// Importa os módulos necessários
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/data.jsondata;

# Representa a configuração do sistema.
#
# + webSocket - Configurações do WebSocket
# + auth - Configurações de autenticação
# + cases - Configurações das "cases"
# + postRequest - Configurações de requisições POST
# + updateInterval - Intervalo de atualização
public type Config record {|
    WebSocket webSocket;
    Auth auth;
    Cases cases;
    PostRequest postRequest;
    UpdateInterval updateInterval;
|};

# Representa as configurações do WebSocket.
#
# + description - Descrição da configuração
# + value - Valor da configuração (URL do WebSocket)
public type WebSocket record {|
    string description;
    string value;
|};

# Representa as configurações de autenticação.
#
# + description - Descrição da configuração
# + value - Credenciais de autenticação
public type Auth record {|
    string description;
    Value value;
|};

# Representa as credenciais de autenticação.
#
# + username - Nome de usuário
# + password - Senha
public type Value record {|
    string username;
    string password;
|};

# Representa as configurações de casos.
#
# + description - Descrição da configuração
# + value - Valor boolean que controla se deve mandar mensagem de comando inexistente.
public type Cases record {|
    string description;
    boolean value;
|};

# Representa as configurações de requisições POST.
#
# + description - Descrição da configuração
# + value - URL para requisições POST
public type PostRequest record {|
    string description;
    string value;
|};

# Representa o intervalo de atualização.
#
# + description - Descrição da configuração
# + value - Intervalo de tempo em segundos
public type UpdateInterval record {|
    string description;
    int value;
|};

# Lê o arquivo de configuração e retorna um objeto Config.
#
# + return - Um objeto Config & readonly ou um erro se a leitura ou conversão falhar
public function readConfig() returns Config & readonly|error {
    string configPath = "settings/config.json";
    string|error fileContent = io:fileReadString(configPath);
    if fileContent is error {
        log:printError("Erro ao ler o arquivo de configuração: " + fileContent.message());
        return fileContent;
    }

    Config|error config = jsondata:parseString(fileContent);
    if config is error {
        log:printError("Erro ao converter JSON para o tipo Config: " + config.message());
        return config;
    }

    // Torna o objeto Config readonly
    return config.cloneReadOnly();
}

# Configuração global do sistema.
public final Config & readonly BAIL_CONFIG = check readConfig();

# Envia uma requisição POST com SSL ignorado.
#
# + url - A URL para a requisição POST
# + data - Os dados a serem enviados no corpo da requisição
# + timeout - O tempo limite da requisição em segundos (padrão: 10)
# + return - A resposta HTTP ou um erro se a requisição falhar
public function postMessage(string url, json data, int timeout = 10) returns http:Response|error {
    // Configura o cliente HTTP para ignorar a verificação SSL
    http:Client httpClient = check new (url, {
        timeout: <decimal>timeout,
        secureSocket: {
            enable: false
        }
    });

    // Cria a requisição HTTP
    http:Request request = new;
    request.setJsonPayload(data);
    request.setHeader("Content-Type", "application/json");
    io:print(data);

    // Envia a requisição POST
    http:Response response = check httpClient->post("", request);

    // Verifica se a requisição foi bem-sucedida
    if response.statusCode >= 400 {
        log:printError("Erro na requisição: " + response.statusCode.toString());
        return error("Erro na requisição: " + response.statusCode.toString());
    }

    return response;
}

# Envia uma mensagem personalizada via requisição POST.
#
# + chatId - O ID do chat para enviar a mensagem
# + msg - A mensagem a ser enviada
# + quoted - A mensagem citada (opcional)
# + code - Código adicional para a requisição
# + return - A resposta JSON ou um erro se o envio falhar
public function sendRaw(string chatId, json msg, json quoted, anydata code) returns json|error {
    json postData = {
        username: BAIL_CONFIG.auth.value.username,
        password: BAIL_CONFIG.auth.value.password,
        code: <string>code,
        chatId: chatId,
        quoted: quoted,
        message: msg
    };

    string url = BAIL_CONFIG.postRequest.value;

    http:Response|error response = postMessage(url, postData);

    if response is error {
        log:printError("Erro ao enviar mensagem: " + response.message());
        return response;
    }

    json|error responseData = response.getJsonPayload();
    if responseData is error {
        log:printError("Erro ao converter resposta para JSON: " + responseData.message());
        return responseData;
    }

    return responseData;
}

# Interface simplificada para enviar uma mensagem.
#
# + chatId - O ID do chat para enviar a mensagem
# + msg - A mensagem a ser enviada
# + quoted - A mensagem citada (opcional)
# + code - Código adicional para a requisição
# + return - A resposta JSON ou um erro se o envio falhar
public function sendMessage(string chatId, json msg, json quoted, anydata code) returns json|error {
    json|error response = sendRaw(chatId, msg, quoted, code);

    if response is error {
        log:printError("Erro ao enviar mensagem: " + response.message());
        return response;
    }

    return response;
}