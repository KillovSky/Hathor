// Importa os módulos que precisa
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/data.jsondata;
import Hathor.Colors;

# Representa a estrutura de um arquivo package.json.
#
# + version - A versão do pacote
# + build_date - A data de build do pacote
# + build_name - O nome do build do pacote
# + homepage - A página inicial do pacote
public type PackageJson record {|
    string version;
    string build_date;
    string build_name;
    string homepage;
|};

# Verifica se há atualizações disponíveis comparando o arquivo package.json local com o remoto.
#
# + timeout - O tempo limite (em segundos) para a requisição HTTP (padrão: 10)
# + return - `true` se uma atualização estiver disponível, `false` caso contrário, ou um erro se algo falhar
public function checkUpdates(decimal timeout = 10) returns boolean|error {
    // Lê e processa o arquivo package.json local
    PackageJson|error localPackage = readLocalPackage("package.json");
    if localPackage is error {
        return localPackage;
    }

    // Busca e processa o arquivo package.json remoto
    PackageJson|error remotePackage = readRemotePackage("https://raw.githubusercontent.com/KillovSky/Hathor/main/package.json", timeout);
    if remotePackage is error {
        return remotePackage;
    }

    // Compara as versões e exibe mensagens apropriadas
    return comparePackages(localPackage, remotePackage);
}

# Lê e converte o arquivo package.json local.
#
# + path - O caminho para o arquivo package.json local
# + return - O conteúdo do arquivo como `PackageJson` ou um erro se a leitura ou conversão falhar
function readLocalPackage(string path) returns PackageJson|error {
    string|error fileContent = io:fileReadString(path);
    if fileContent is error {
        log:printError("Erro ao ler o arquivo local: " + fileContent.message());
        return fileContent;
    }

    PackageJson|error package = jsondata:parseString(fileContent);
    if package is error {
        log:printError("Erro ao converter JSON local: " + package.message());
        return package;
    }

    return package;
}

# Busca e converte o arquivo package.json remoto.
#
# + url - A URL do arquivo package.json remoto
# + timeout - O tempo limite (em segundos) para a requisição HTTP
# + return - O conteúdo do arquivo como `PackageJson` ou um erro se a requisição ou conversão falhar
function readRemotePackage(string url, decimal timeout) returns PackageJson|error {
    http:Client httpClient = check new ("https://raw.githubusercontent.com", { timeout: timeout });

    http:Response response = <http:Response> check httpClient->get("/KillovSky/Hathor/main/package.json");
    if response.statusCode >= 400 {
        log:printError("Erro ao verificar a versão remota: " + response.statusCode.toString());
        return error("Erro ao verificar a versão remota: " + response.statusCode.toString());
    }

    string|error fileContent = response.getTextPayload();
    if fileContent is error {
        log:printError("Erro ao obter o conteúdo remoto: " + fileContent.message());
        return fileContent;
    }

    PackageJson|error package = jsondata:parseString(fileContent);
    if package is error {
        log:printError("Erro ao converter JSON remoto: " + package.message());
        return package;
    }

    return package;
}

# Compara dois pacotes e exibe mensagens apropriadas.
#
# + localPackage - O pacote local
# + remotePackage - O pacote remoto
# + return - `true` se uma atualização estiver disponível, `false` caso contrário
function comparePackages(PackageJson localPackage, PackageJson remotePackage) returns boolean {
    if (localPackage.version == remotePackage.version &&
        localPackage.build_date == remotePackage.build_date &&
        localPackage.build_name == remotePackage.build_name) {

        string message = Colors:colorfy("[VERSION] ", "cyan") + Colors:colorfy("Valeu por me manter atualizada!", "green");
        io:println(message);
        return false; // Não precisa de atualização
    } else {
        string message = Colors:colorfy("[VERSION] ", "cyan") +
            Colors:colorfy("ATUALIZAÇÃO DISPONÍVEL ", "red") +
            "→ [" +
            Colors:colorfy(remotePackage.version, "magenta") + " ~ " +
            Colors:colorfy(remotePackage.build_name, "blue") + " ~ " +
            Colors:colorfy(remotePackage.build_date, "yellow") + "] | " +
            Colors:colorfy(remotePackage.homepage, "green");
        io:println(message);
        return true; // Precisa de atualização
    }
}