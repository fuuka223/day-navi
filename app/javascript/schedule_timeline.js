window.showDetail = function(title, time) {
  const sheet = document.getElementById('bottom-sheet');
  if (!sheet) return;
  document.getElementById('sheet-title').innerText = title;
  document.getElementById('sheet-time').innerText = time;
  sheet.classList.add('show');
};

window.hideDetail = function() {
  const sheet = document.getElementById('bottom-sheet');
  if (sheet) sheet.classList.remove('show');
};

window.createNewSchedule = function(event) {
  // 予定の帯をクリックした時は新規作成を発動させない
  if (event.target.closest('.swipe-content')) return;

  const timeline = document.getElementById('timeline');
  const rect = timeline.getBoundingClientRect();
  const y = event.clientY - rect.top;
  const hour = Math.floor(y / 60);
  
  window.location.href = `/schedules/new?start_hour=${hour}`;
};

// スワイプ処理
document.addEventListener("touchstart", (e) => {
  const content = e.target.closest('.swipe-content');
  if (!content) return;

  content.startX = e.touches[0].clientX;
});

document.addEventListener("touchmove", (e) => {
  const content = e.target.closest('.swipe-content');
  if (!content || content.startX === undefined) return;

  let touch = e.touches[0];
  let change = content.startX - touch.clientX;

  if (change > 50) {
    content.style.transform = 'translateX(-120px)'; // スライド
  } else if (change < -50) {
    content.style.transform = 'translateX(0)';      // 戻す
  }
});
