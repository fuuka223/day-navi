document.addEventListener("turbo:load", () => {
  const form = document.querySelector(".task-form");
  if (!form) return;

  // 1. 要素の取得
  const inputs = form.querySelectorAll(".js-input");
  const submitBtn = form.querySelector(".js-submit");
  const prioritySelect = form.querySelector(".js-priority-select");
  const indicator = form.querySelector(".js-priority-indicator");

  // 2. 優先度プレビュー機能
  const updatePriorityPreview = () => {
    if (!prioritySelect || !indicator) return;

    const priorityColors = {
      "1": "#ff4d4d", // 重要・緊急
      "2": "#ffb347", // 重要・非緊急
      "3": "#77dd77", // 非重要・緊急
      "4": "#f0f0f0"  // 非重要・非緊急
    };

    const selectedValue = prioritySelect.value;
    indicator.style.backgroundColor = priorityColors[selectedValue] || "#f0f0f0";
  };

  if (prioritySelect) {
    prioritySelect.addEventListener("change", updatePriorityPreview);
    updatePriorityPreview();
  }

  // 3. 入力管理（文字数カウント & フォーカス）
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

  // 4. 送信制御
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