// Importa os módulos que precisa
import ballerina/io;
import ballerina/lang.runtime;
import ballerina/time;
import ballerina/websocket;
import Hathor.Colors;
import Hathor.Update;
import Hathor.Commands;
import Hathor.Kill;

# Inicia o worker que se conecta ao WebSocket e processa mensagens.
#
# + return - Um erro se ocorrer um problema durante a execução do worker
public function startWorker() returns error {
    // Obtem a configuração
    var config = Kill:BAIL_CONFIG;

    // Obtém a URL do WebSocket, username e password da configuração
    string websocketUrl = config.webSocket.value;
    string username = config.auth.value.username;
    string password = config.auth.value.password;

    // Configura e inicializa o cliente WebSocket
    websocket:Client chatClient = check new (websocketUrl,
        auth = {
            username: username,
            password: password
        },
        secureSocket = {
            enable: false
        }
    );

    // Inicializa o tempo Unix para controle de atualizações
    int unixTime = <int>time:monotonicNow();

    // Loop principal para processar mensagens recebidas
    while true {
        // Verifica se é hora de checar por atualizações
        int currentUnixTime = <int>time:monotonicNow();
        if currentUnixTime > unixTime {
            io:println(Colors:colorfy("Checando por atualizações...", "yellow"));
            boolean _ = check Update:checkUpdates();
            unixTime = currentUnixTime + config.updateInterval.value;
        }

        // Lê e processa a mensagem recebida do WebSocket
        string message = check chatClient->readMessage();
        json|error jsonData = message.fromJsonString();

        // Verifica se o JSON foi parseado corretamente
        if jsonData is json {
            processJsonMessage(jsonData);
        } else {
            io:println("Erro ao parsear JSON: ", jsonData);
        }

        // Aguarda 1 segundo antes de continuar
        runtime:sleep(1);
    }
}

# Processa uma mensagem JSON recebida do WebSocket, redireciona para o sistema de comandos.
#
# + jsonData - O JSON recebido para processamento
function processJsonMessage(json jsonData) {
    if jsonData.printerMessage is string {
        io:println(jsonData.printerMessage);
    } else if jsonData.isCmd is boolean {
        if jsonData.isCmd == true {
            io:println(Colors:colorfy("[LEGACY MODE ~ COMANDO] ", "red"), jsonData.command);
        } else {
            io:println(Colors:colorfy("[LEGACY MODE ~ MENSAGEM] ", "red"), jsonData.body);
        }
    } else if jsonData.startlog is boolean && jsonData.startlog == true {
        io:println(Colors:colorfy("Conexão realizada com sucesso, aguardando mensagens...", "green"));
    } else {
        io:println(Colors:colorfy("Resposta desconhecida:", "red"), jsonData);
    }

    // Processa a mensagem usando o módulo Commands
    io:println(Commands:processMessages(<map<json>>jsonData));
}