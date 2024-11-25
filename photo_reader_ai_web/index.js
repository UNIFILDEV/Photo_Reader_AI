document.getElementById("imageInput").addEventListener("change", function () {
  const imageInput = document.getElementById("imageInput");
  const analiseBtn = document.getElementById("analiseBtn");

  if (imageInput.files.length > 0) {
    displayImage(imageInput.files[0]);
    analiseBtn.disabled = false;
  } else {
    analiseBtn.disabled = true;
  }
});

document
  .getElementById("uploadForm")
  .addEventListener("submit", async function (event) {
    event.preventDefault();

    const imageInput = document.getElementById("imageInput");
    const progressBar = document.getElementById("progressBar");
    const resultDiv = document.getElementById("result");

    if (imageInput.files.length === 0) {
      M.toast({ html: "Upload de uma imagen!" });
      return;
    }

    const file = imageInput.files[0];
    const reader = new FileReader();

    reader.onloadstart = function () {
      progressBar.style.display = "block";
    };

    reader.onloadend = async function () {
      const base64Image = reader.result.split(",")[1];
      const apiKey = "AIzaSyAZ4YBfvklEuNYJyfFMnLaOUKtLFAH36SQ";

      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            contents: [
              {
                parts: [
                  { text: "O que é essa foto?" },
                  {
                    inline_data: {
                      mime_type: "image/png",
                      data: base64Image,
                    },
                  },
                ],
              },
            ],
          }),
        }
      );

      progressBar.style.display = "none";

      if (response.ok) {
        const data = await response.json();
        displayResult(data);
      } else {
        M.toast({ html: "Erro!" });
        resultDiv.innerHTML = "";
      }
    };

    reader.readAsDataURL(file);
  });

function displayImage(file) {
  const imagePreview = document.getElementById("imagePreview");
  const reader = new FileReader();

  reader.onload = function (event) {
    imagePreview.innerHTML = `<img src="${event.target.result}" alt="Image Preview">`;
  };

  reader.readAsDataURL(file);
}

function displayResult(data) {
  const resultDiv = document.getElementById("result");
  resultDiv.innerHTML = "";

  if (data && data.candidates && data.candidates.length > 0) {
    const candidate = data.candidates[0];

    const content =
      candidate.content && candidate.content.parts
        ? candidate.content.parts.map((part) => part.text).join(" ")
        : "Descrição não disponível.";

    const safetyRatings = candidate.safetyRatings
      ? candidate.safetyRatings
          .map((rating) => `<li>${rating.category}: ${rating.probability}</li>`)
          .join("")
      : "Nenhuma avaliação de segurança disponível.";

    resultDiv.innerHTML = `
      <h5>Resultado:</h5>
      <p>${content}</p>
    `;
  } else {
    resultDiv.innerHTML = "<p>Não foi possível processar a descrição da imagem.</p>";
  }
}

