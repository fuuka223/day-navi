document.addEventListener("turbo:load", () => {
  const container = document.querySelector('[data-controller="task-list"]');
  if (!container) return;

  // 1. 完了ボタンの即時反映
  container.addEventListener("click", (e) => {
    const toggleBtn = e.target.closest(".js-toggle");
    if (!toggleBtn) return;

    const card = toggleBtn.closest(".task-card");
    const title = card.querySelector(".task-title");
    const isCompleted = card.getAttribute("data-completed") === "true";

    const nextState = !isCompleted;
    card.setAttribute("data-completed", nextState);
    toggleBtn.innerText = nextState ? "✅" : "⬜️";
    
    if (title) title.style.textDecoration = nextState ? "line-through" : "none";
    card.style.opacity = nextState ? "0.6" : "1";
    
  });

  // 2. ホバーエフェクト
  container.addEventListener("mouseover", (e) => {
    const card = e.target.closest(".task-card");
    if (card) {
      card.style.transform = "translateY(-2px)";
      card.style.boxShadow = "0 6px 15px rgba(0,0,0,0.1)";
      card.style.transition = "all 0.2s ease";
    }
  });

  container.addEventListener("mouseout", (e) => {
    const card = e.target.closest(".task-card");
    if (card) {
      card.style.transform = "translateY(0)";
      card.style.boxShadow = "0 2px 5px rgba(0,0,0,0.05)";
    }
  });

  // 3. ＋ボタンの演出
  const fab = container.querySelector(".fab");
  if (fab) {
    fab.addEventListener("mousedown", () => fab.style.transform = "scale(0.8)");
    fab.addEventListener("mouseup", () => fab.style.transform = "scale(1)");
  }
});