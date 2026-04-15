// app/javascript/schedule_timeline.js

// 現在表示している予定のIDを保持する変数
let currentActiveId = null;

// --- 詳細表示 ---
window.showDetail = function(title, time, event) {
  const target = event.currentTarget;
  const scheduleId = target.getAttribute('data-id');
  const sheet = document.getElementById('bottom-sheet');
  
  if (!sheet) return;

  // すでに開いている予定と同じIDをクリックしたら閉じる
  if (sheet.classList.contains('show') && currentActiveId === scheduleId) {
    hideDetail();
  } else {
    // 別の予定をクリック、または閉じていた場合は詳細を表示
    document.getElementById('sheet-title').innerText = title;
    document.getElementById('sheet-time').innerText = time;
    sheet.classList.add('show');
    currentActiveId = scheduleId;
  }
};

window.hideDetail = function() {
  const sheet = document.getElementById('bottom-sheet');
  if (sheet) {
    sheet.classList.remove('show');
    currentActiveId = null;
  }
};

// --- 新規予定作成 ---
window.createNewSchedule = function(event) {
  if (event.target.closest('.swipe-content') || event.target.closest('.swipe-actions')) return;

  const timeline = document.getElementById('timeline');
  const rect = timeline.getBoundingClientRect();
  const y = event.clientY - rect.top;
  const hour = Math.floor(y / 60);
  
  hideDetail();
  
  window.location.href = `/schedules/new?start_hour=${hour}`;
};

// --- スワイプ処理の関数定義 ---
const startSwipe = (e) => {
  const content = e.target.closest('.swipe-content');
  if (!content) return;
  content.startX = e.type.includes('mouse') ? e.clientX : e.touches[0].clientX;
};

const moveSwipe = (e) => {
  const content = e.target.closest('.swipe-content');
  if (!content || content.startX === undefined) return;

  let currentX = e.type.includes('mouse') ? e.clientX : e.touches[0].clientX;
  let change = content.startX - currentX;

  if (change > 50) {
    content.style.transform = 'translateX(-120px)';
  } else if (change < -50) {
    content.style.transform = 'translateX(0)';
  }
};

const endSwipe = (e) => {
  const content = e.target.closest('.swipe-content');
  if (content) content.startX = undefined;
};

// --- イベントの個別登録 ---
// マウスイベント
document.addEventListener("mousedown", (e) => {
  startSwipe(e);
});

document.addEventListener("mousemove", (e) => {
  moveSwipe(e);
});

document.addEventListener("mouseup", (e) => {
  endSwipe(e);
});

// タッチイベント
document.addEventListener("touchstart", (e) => {
  startSwipe(e);
}, { passive: true });

document.addEventListener("touchmove", (e) => {
  moveSwipe(e);
}, { passive: true });

document.addEventListener("touchend", (e) => {
  endSwipe(e);
});

// Turbo環境での読み込み確認
document.addEventListener("turbo:load", () => {
  console.log("Timeline JS loaded and Turbo ready!");
});