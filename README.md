# Photo_Reader_AI
<details>
   <summary>⚙️ Funcionalidades e Dependências</summary>

## Aplicativo de Interpretação de Imagem para Deficientes Visuais

Este projeto é um aplicativo acessível para dispositivos móveis que utiliza tecnologias de visão computacional para ajudar pessoas com deficiência visual a interpretar e entender imagens. O aplicativo permite que o usuário tire uma foto ou selecione uma imagem da galeria, e então fornece uma descrição detalhada do conteúdo visual.

## Funcionalidades

- **Captura e seleção de imagem**: O usuário pode tirar uma foto usando a câmera do dispositivo ou selecionar uma imagem salva na galeria.
- **Descrição de imagens**: O aplicativo utiliza uma API de visão computacional para gerar uma descrição detalhada do que está na imagem, incluindo informações como objetos, pessoas, cores e contextos.
- **Leitura em voz alta**: A descrição gerada é lida em voz alta para o usuário através de um recurso de síntese de voz.
- **Interface de usuário acessível**: Interface otimizada para navegação assistida por leitor de tela, com botões e elementos de fácil acesso e grande contraste.

## Como Usar

1. **Abrir o Aplicativo**: O usuário abre o aplicativo em seu dispositivo móvel.
2. **Selecionar Imagem**: Escolha entre tirar uma nova foto ou selecionar uma imagem da galeria.
3. **Gerar Descrição**: Toque no botão "Descrever Imagem" para enviar a imagem para o processamento.
4. **Ouvir Descrição**: O aplicativo irá ler em voz alta a descrição da imagem, ajudando o usuário a entender o conteúdo visual.

## Pré-requisitos

- **Android 5.0+**.
- Conexão com a internet

**Nota**: Este aplicativo tem como objetivo auxiliar pessoas com deficiência visual e deve ser utilizado em conjunto com outros recursos de acessibilidade oferecidos pelo sistema operacional do dispositivo.
</details>

<details>
   <summary>🚀 Configuração de Ambiente para Aplicação Mobile com Flutter</summary>

Este guia explica como configurar o ambiente de desenvolvimento para criar uma aplicação mobile usando **Flutter** em **Linux** e **Windows**.

## 📋 Pré-requisitos

- **🖥️ Sistema Operacional**:  
  Windows, macOS ou Linux.

- **💾 Espaço em Disco**:  
  Aproximadamente 1.64 GB para o SDK do Flutter.

- **🔧 Ferramentas Necessárias**:  
  - [Git](https://git-scm.com/)  
  - [Android Studio](https://developer.android.com/studio)

---

## 📱 Configuração do Android

1. **Versão Mínima do Android**:  
   - **Android 11 (API 30)** ou superior.

2. **Ferramentas Necessárias**:  
   - Abra o Android Studio e vá para:  
     **`Settings > Appearance & Behavior > System Settings > Android SDK`**  
     Certifique-se de que o SDK do Android 11+ está instalado.

3. **Emulador ou Dispositivo Físico**:  
   - Configure um **Emulador** com Android 11+.
   - Caso utilize um dispositivo físico:  
     - Ative o modo **Depuração USB**.  
     - Libere a opção **Instalar via USB** (se disponível).

---

## ☕ Configuração do Java

1. **Java 11+**  
   - Verifique se o Java 11 está instalado:  
     ```bash
     java -version
     ```
     Exemplo de saída:  
     ```plaintext
     java version "11.0.x"
     ```
   - Caso não esteja instalado, baixe e instale o [OpenJDK 11](https://openjdk.org/install/).

---

## 🛠️ Instalar o Flutter

### 💻🐧 Linux

1. **Baixar o Flutter SDK**  
   ```bash
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.0-stable.tar.xz
   ```

2. **Extrair o SDK**  
   ```bash
   tar xf flutter_linux_3.13.0-stable.tar.xz -C $HOME
   ```

3. **Adicionar ao PATH**  
   Edite o arquivo `.bashrc` ou `.zshrc`:  
   ```bash
   export PATH="$PATH:$HOME/flutter/bin"
   ```
   Atualize o terminal:  
   ```bash
   source ~/.bashrc
   ```

4. **Verificar a Instalação**  
   ```bash
   flutter doctor
   ```

### 🖥️🪟 Windows

1. **Baixar o Flutter SDK**  
   [Baixe o SDK Flutter para Windows](https://flutter-ko.dev/get-started/install/windows).

2. **Extrair o SDK**  
   Extraia o conteúdo do `.zip` para `C:\src\flutter`.

3. **Adicionar ao PATH**  
   - Abra **Editar Variáveis de Ambiente do Sistema** no menu Iniciar.  
   - Adicione `C:\src\flutter\bin` à variável **PATH**.

4. **Verificar a Instalação**  
   No **Prompt de Comando** ou **PowerShell**, execute:  
   ```bash
   flutter doctor
   ```

---

## 🖥️ Instalar o Android Studio

1. **Baixar e Instalar o Android Studio**  
   Baixe em: [Android Studio](https://developer.android.com/studio?hl=pt-br).

2. **Configurar o SDK do Android**  
   - No Android Studio, vá para:  
     **`Preferências > Aparência e Comportamento > Configurações do Sistema > Android SDK`**  
     Instale as SDKs recomendadas.

3. **Criar um Emulador (opcional)**  
   - Use o **AVD Manager** no Android Studio para criar um dispositivo virtual.

4. **Aceitar Licenças do Android**  
   Execute no terminal:  
   ```bash
   flutter doctor --android-licenses
   ```

---

## ✅ Verificação Final

Após seguir todos os passos, execute o comando abaixo para confirmar que o ambiente está configurado corretamente:  
```bash
flutter doctor
```
Certifique-se de que todas as dependências estão marcadas como **[✓]**.

---

**📝 Nota**: Para mais informações, consulte a [documentação oficial do Flutter](https://docs.flutter.dev).

</details>

<details>
   <summary>🌐 API Google Cloud</summary>

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
</details>

<details>
   <summary>Gerar e Distribuir o APK do Projeto</summary>

Siga os passos abaixo para gerar a versão de **release** (distribuição) do APK do aplicativo.


## **Pré-requisitos**
- Certifique-se de ter o **Flutter** instalado e configurado corretamente na máquina.
- Verifique se o ambiente Android está configurado com o **SDK**, **NDK** e **JDK** compatíveis.
- Confirme que você possui os seguintes arquivos:
  - `key.properties`
  - `photo_reader_ai_release.jks`


## **Passos para Gerar o APK**

### **1. Preparar os Arquivos de Assinatura**
1. **Copie os arquivos necessários:**
   - Copie o arquivo `key.properties` da pasta raiz do projeto para o caminho:
     ```bash
     android/key.properties
     ```
   - Copie o arquivo `photo_reader_ai_release.jks` da pasta raiz do projeto para o caminho:
     ```bash
     android/app/photo_reader_ai_release.jks
     ```

## **Executar o Projeto**
Para rodar o projeto diretamente em um dispositivo físico ou emulador, use o seguinte comando:

```bash
flutter run
```

## **Observações**
- Certifique-se de que o dispositivo físico está conectado e com a **depuração USB** ativada, ou que o emulador Android está em execução.
- O APK gerado no modo release é otimizado para distribuição e não inclui ferramentas de depuração.
- Antes de distribuir o APK, teste-o em diferentes dispositivos para garantir a compatibilidade.
</details>