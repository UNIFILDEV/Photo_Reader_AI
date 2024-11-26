# Photo_Reader_AI
## Aplicativo de Interpretação de Imagem para Deficientes Visuais

Este projeto é um aplicativo acessível para dispositivos móveis que utiliza tecnologias de visão computacional para ajudar pessoas com deficiência visual a interpretar e entender imagens. O aplicativo permite que o usuário tire uma foto ou selecione uma imagem da galeria, e então fornece uma descrição detalhada do conteúdo visual.

## Funcionalidades

- **Captura e seleção de imagem**: O usuário pode tirar uma foto usando a câmera do dispositivo ou selecionar uma imagem salva na galeria.
- **Descrição de imagens**: O aplicativo utiliza uma API de visão computacional para gerar uma descrição detalhada do que está na imagem, incluindo informações como objetos, pessoas, cores e contextos.
- **Leitura em voz alta**: A descrição gerada é lida em voz alta para o usuário através de um recurso de síntese de voz.
- **Interface de usuário acessível**: Interface otimizada para navegação assistida por leitor de tela, com botões e elementos de fácil acesso e grande contraste.
- **Modo offline**: Algumas funcionalidades podem ser usadas mesmo sem conexão com a internet, como navegação e histórico de imagens já descritas.

## Como Usar

1. **Abrir o Aplicativo**: O usuário abre o aplicativo em seu dispositivo móvel.
2. **Selecionar Imagem**: Escolha entre tirar uma nova foto ou selecionar uma imagem da galeria.
3. **Gerar Descrição**: Toque no botão "Descrever Imagem" para enviar a imagem para o processamento.
4. **Ouvir Descrição**: O aplicativo irá ler em voz alta a descrição da imagem, ajudando o usuário a entender o conteúdo visual.

## Pré-requisitos

- **Android 5.0+**.
- Conexão com a internet

**Nota**: Este aplicativo tem como objetivo auxiliar pessoas com deficiência visual e deve ser utilizado em conjunto com outros recursos de acessibilidade oferecidos pelo sistema operacional do dispositivo.


# Configuração do Arquivo `secrets.dart`

Para garantir a segurança da chave da API utilizada neste projeto, a chave é armazenada em um arquivo local chamado `secrets.dart`. Este arquivo **não está incluído no repositório** e deve ser gerado manualmente seguindo as instruções abaixo.

## 1. Obter a chave da API no Google Cloud
1. Acesse o console do Google Cloud: [Google Cloud Console - APIs & Credentials](https://console.cloud.google.com/apis/credentials).
2. Selecione ou crie um projeto no Google Cloud.
3. Na seção **Credenciais**, clique em **Criar credenciais** e escolha **Chave de API**.
4. Copie a chave gerada e guarde-a temporariamente.

## 2. Criar o arquivo `secrets.dart`
1. No diretório `lib/` do projeto Flutter, crie um arquivo chamado `secrets.dart`.
2. Adicione o seguinte conteúdo ao arquivo, substituindo `SUA_API_KEY_AQUI` pela chave gerada no passo anterior:

    ```dart
    const String apiKey = "SUA_API_KEY_AQUI";
    ```
3. Garanta que a api do Gemini API está habilitada no teu projeto do Google Cloud.