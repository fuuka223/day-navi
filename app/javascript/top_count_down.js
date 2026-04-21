document.addEventListener("turbo:load", () => {
  const countdownContainer = document.getElementById("countdown-display");
  // 中身を書き換えるための特定の要素を取得
  const timerElement = document.getElementById("countdown-timer");
  const titleElement = document.getElementById("next-schedule-title");

  if (!countdownContainer || !timerElement) return;

  const schedulesData = JSON.parse(countdownContainer.dataset.schedules);

  const updateCountdown = () => {
    const now = new Date();

    // 1. 未来の予定（開始時刻が「今」より後）だけを抽出して、近い順に並べる
    const futureSchedules = schedulesData
      .map(s => ({ ...s, startTime: new Date(s.start_time.replace('Z', '')) }))
      .filter(s => s.startTime > now)
      .sort((a, b) => a.startTime - b.startTime);

    // 2. 次の予定がない場合
    if (futureSchedules.length === 0) {
      timerElement.innerText = "--:--:--";
      if (titleElement) titleElement.innerText = "今日の予定はすべて終了しました";
      return;
    }

    // 3. 一番近い次の予定を取得
    const next = futureSchedules[0];
    const diffMs = next.startTime - now;

    // 時間・分・秒の計算
    const hours = Math.floor(diffMs / (1000 * 60 * 60));
    const minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diffMs % (1000 * 60)) / 1000);

    // 表示の更新
    timerElement.innerText = `${hours}:${minutes}:${seconds}`;
    if (titleElement) {
      titleElement.innerText = next.title;
    }
  };

  // 1秒ごとに更新
  setInterval(updateCountdown, 1000);
  updateCountdown();
});