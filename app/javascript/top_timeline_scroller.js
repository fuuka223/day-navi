document.addEventListener("turbo:load", () => {
  const line = document.getElementById("current-time-line");
  const wrapper = document.querySelector(".timeline-wrapper");

  if (!line || !wrapper) return;

  const updateTimeline = () => {
    const now = new Date();
    const hours = now.getHours();
    const minutes = now.getMinutes();
    
    // 00:00からの経過分 = 座標(px)
    const totalMinutes = (hours * 60) + minutes;

    // 赤いラインを現在の位置へ
    line.style.top = `${totalMinutes}px`;

    // 現在時刻を枠の最上部へスクロール
    wrapper.scrollTo({
      top: totalMinutes,
      behavior: 'auto'
    });

    console.log(`スクロール実行: ${hours}:${minutes} (${totalMinutes}px地点)`);
  };

  // 初回実行
  updateTimeline();
  
  // 1分ごとにラインの位置だけ更新
  setInterval(() => {
    const now = new Date();
    const totalMinutes = (now.getHours() * 60) + now.getMinutes();
    line.style.top = `${totalMinutes}px`;
  }, 60000);
});