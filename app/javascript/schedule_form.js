document.addEventListener("turbo:load", () => {

  const form = document.querySelector("form");
  const inputs = document.querySelectorAll(".form-input, .form-textarea");
  const submitBtn = document.querySelector('input[type="submit"], button[type="submit"]');

  if (!form || inputs.length === 0) return;

  // 1.入力
  inputs.forEach(input => {
    const group = input.closest(".form-group");
    if (!group) return;

    const countDisplay = group.querySelector(".char-count");

    // フォーカス時のスタイル
    input.addEventListener("focus", () => group.classList.add("is-active"));
    input.addEventListener("blur", () => group.classList.remove("is-active"));

    // 文字数カウント処理
    const isTitle = input.name && input.name.includes("title");
    const isContent = input.name && input.name.includes("content");

    if (isTitle || isContent) {
      const maxLength = isTitle ? 50 : 1000;

      const updateCount = () => {
        const length = input.value.length;
        const remaining = maxLength - length;

        if (countDisplay) {
          countDisplay.innerText = `${length}/${maxLength}`;
          
          // 文字数超過で赤くする
          if (length > maxLength) {
            countDisplay.classList.add("is-error");
          } else {
            countDisplay.classList.remove("is-error");
          }
        }

        // 入力枠自体のエラー表示
        input.classList.toggle("is-invalid", length > maxLength);
      };
      
      input.addEventListener("input", updateCount);
      updateCount();
    }
  });

  // 2.送信制御
  form.addEventListener("submit", (e) => {
    const hasError = form.querySelector(".is-invalid");
    if (hasError) {
      e.preventDefault();
      alert("入力文字数を確認してください。");
      return;
    }

    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.innerText = "保存中...";
      submitBtn.classList.add("is-loading");
    }
  });
});