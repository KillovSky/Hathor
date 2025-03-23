// Importa os módulos que precisa
import ballerina/log;
import ballerina/file;

# Dicionário de códigos ANSI para cores e estilos de texto.
public const COLORS = {
    "reset": ["\u{001B}[0m", "\u{001B}[0m"],
    "bold": ["\u{001B}[1m", "\u{001B}[22m"],
    "dim": ["\u{001B}[2m", "\u{001B}[22m"],
    "italic": ["\u{001B}[3m", "\u{001B}[23m"],
    "underline": ["\u{001B}[4m", "\u{001B}[24m"],
    "inverse": ["\u{001B}[7m", "\u{001B}[27m"],
    "hidden": ["\u{001B}[8m", "\u{001B}[28m"],
    "strikethrough": ["\u{001B}[9m", "\u{001B}[29m"],
    "black": ["\u{001B}[30m", "\u{001B}[39m"],
    "red": ["\u{001B}[31m", "\u{001B}[39m"],
    "green": ["\u{001B}[32m", "\u{001B}[39m"],
    "yellow": ["\u{001B}[33m", "\u{001B}[39m"],
    "blue": ["\u{001B}[34m", "\u{001B}[39m"],
    "magenta": ["\u{001B}[35m", "\u{001B}[39m"],
    "cyan": ["\u{001B}[36m", "\u{001B}[39m"],
    "white": ["\u{001B}[37m", "\u{001B}[39m"],
    "gray": ["\u{001B}[90m", "\u{001B}[39m"],
    "grey": ["\u{001B}[90m", "\u{001B}[39m"],
    "brightRed": ["\u{001B}[91m", "\u{001B}[39m"],
    "brightGreen": ["\u{001B}[92m", "\u{001B}[39m"],
    "brightYellow": ["\u{001B}[93m", "\u{001B}[39m"],
    "brightBlue": ["\u{001B}[94m", "\u{001B}[39m"],
    "brightMagenta": ["\u{001B}[95m", "\u{001B}[39m"],
    "brightCyan": ["\u{001B}[96m", "\u{001B}[39m"],
    "brightWhite": ["\u{001B}[97m", "\u{001B}[39m"],
    "bgBlack": ["\u{001B}[40m", "\u{001B}[49m"],
    "bgRed": ["\u{001B}[41m", "\u{001B}[49m"],
    "bgGreen": ["\u{001B}[42m", "\u{001B}[49m"],
    "bgYellow": ["\u{001B}[43m", "\u{001B}[49m"],
    "bgBlue": ["\u{001B}[44m", "\u{001B}[49m"],
    "bgMagenta": ["\u{001B}[45m", "\u{001B}[49m"],
    "bgCyan": ["\u{001B}[46m", "\u{001B}[49m"],
    "bgWhite": ["\u{001B}[47m", "\u{001B}[49m"],
    "bgGray": ["\u{001B}[100m", "\u{001B}[49m"],
    "bgGrey": ["\u{001B}[100m", "\u{001B}[49m"],
    "bgBrightRed": ["\u{001B}[101m", "\u{001B}[49m"],
    "bgBrightGreen": ["\u{001B}[102m", "\u{001B}[49m"],
    "bgBrightYellow": ["\u{001B}[103m", "\u{001B}[49m"],
    "bgBrightBlue": ["\u{001B}[104m", "\u{001B}[49m"],
    "bgBrightMagenta": ["\u{001B}[105m", "\u{001B}[49m"],
    "bgBrightCyan": ["\u{001B}[106m", "\u{001B}[49m"],
    "bgBrightWhite": ["\u{001B}[107m", "\u{001B}[49m"],
    "blackBG": ["\u{001B}[40m", "\u{001B}[49m"],
    "redBG": ["\u{001B}[41m", "\u{001B}[49m"],
    "greenBG": ["\u{001B}[42m", "\u{001B}[49m"],
    "yellowBG": ["\u{001B}[43m", "\u{001B}[49m"],
    "blueBG": ["\u{001B}[44m", "\u{001B}[49m"],
    "magentaBG": ["\u{001B}[45m", "\u{001B}[49m"],
    "cyanBG": ["\u{001B}[46m", "\u{001B}[49m"],
    "whiteBG": ["\u{001B}[47m", "\u{001B}[49m"]
};

# Aplica cores e estilos ANSI a um texto.
#
# + text - O texto a ser colorido (pode ser nulo)
# + color - A cor ou estilo a ser aplicado (padrão: "green")
# + return - O texto colorido ou uma mensagem de erro formatada
public function colorfy(string? text, string color = "green") returns string {
    // Mensagem padrão para texto nulo ou inválido
    string defaultMessage = string `\u{001B}[31m[${file:getCurrentDir()}]\u{001B}[39m → \u{001B}[33mThe operation cannot be completed because no text has been sent.\u{001B}[39m`;

    // Obtém os códigos ANSI para a cor especificada ou usa "green" como padrão
    string[] colorCodes = COLORS[color] ?: COLORS["green"];

    // Verifica se o texto é válido
    if text is string {
        return string `${colorCodes[0]}${text}${colorCodes[1]}`;
    } else {
        // Log de erro para texto inválido
        log:printError("A mensagem deve ser uma string. Mensagem recebida: " + text.toString());
        return defaultMessage;
    }
}