// Importa os módulos que precisa
import Hathor.Kill;

// Constantes para comandos e mensagens
const string COMMAND_BALLERINA_TEST = "ballerinatest123+@";
const string COMMAND_BALLERINA_TEST_SPACED = "ballerina test 123 +@";
const string COMMAND_BALLERINA_TEST_UPPERCASE = "BALLERINA TEST 123 +@";
const string MESSAGE_OK = "✔️ OK!";
const string MESSAGE_UNKNOWN_COMMAND = "Esse comando não existe ainda!";

# Verifica se um comando corresponde a um nome específico.
#
# + command - O comando a ser verificado
# + name - O nome do comando esperado
# + onlyCmd - Se `true`, verifica apenas comandos com prefixo
# + isCmd - Indica se o comando atual tem prefixo
# + return - `true` se o comando corresponder ao nome, falso caso contrário
public function isCommandMatch(string command, string name, boolean onlyCmd, boolean isCmd) returns boolean {
    return (onlyCmd && isCmd && command == name) || (!onlyCmd && command == name);
}

# Envia uma mensagem de resposta.
#
# + chatId - O ID do chat para enviar a mensagem
# + message - A mensagem a ser enviada
# + reply - O ID da mensagem para responder (opcional)
# + isRaw - Indica se a mensagem deve ser enviada como raw
# + return - Um erro se ocorrer um problema ao enviar a mensagem
function sendResponse(string chatId, string message, json|boolean reply, boolean isRaw) returns error? {
    map<json> messageMap = {text: message};
    if isRaw {
        var sendResult = Kill:sendRaw(chatId, messageMap, reply, false);
        if sendResult is error {
            return error("Erro ao enviar mensagem raw: " + sendResult.message());
        }
    } else {
        var sendResult = Kill:sendMessage(chatId, messageMap, reply, false);
        if sendResult is error {
            return error("Erro ao enviar mensagem: " + sendResult.message());
        }
    }
    return;
}

# Função principal para processar mensagens.
#
# + env - Um mapa contendo os dados da mensagem (chatId, isCmd, reply, command, body)
# + return - Um erro se ocorrer um problema durante o processamento
public function processMessages(map<json> env) returns error? {
    // Extrai e converte os dados da mensagem
    string chatId = env["chatId"].toString();
    boolean isCmd = env["isCmd"] is boolean ? <boolean>env["isCmd"] : false;
    string command = isCmd ? env["command"].toString() : env["body"].toString();
    json|boolean reply = env["reply"];

    // Verifica se o comando corresponde a um dos casos esperados
    if isCommandMatch(command, COMMAND_BALLERINA_TEST, false, isCmd) ||
       isCommandMatch(command, COMMAND_BALLERINA_TEST_SPACED, false, isCmd) ||
       isCommandMatch(command, COMMAND_BALLERINA_TEST_UPPERCASE, false, isCmd) {
        return sendResponse(chatId, MESSAGE_OK, reply, false);
    }

    // Se for um comando com prefixo e a configuração permitir, envia uma resposta raw
    if isCmd {
        var config = Kill:BAIL_CONFIG;
        if config.cases?.value == true {
            return sendResponse(chatId, MESSAGE_UNKNOWN_COMMAND, reply, true);
        }
    }

    return;
}