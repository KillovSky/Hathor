// Importa os módulos que precisa
import Hathor.Initialize;

# Função principal para executar o script.
#
# + return - Retorna `error?` que pode ser um erro caso ocorra algum problema durante a execução.
public function main() returns error? {
    // Chamando a função `startWorker` do módulo `Initialize`.
    check Initialize:startWorker();
}