// 現在表示している予定のIDを保持する変数
let currentActiveId = null;

// ---詳細表示の制御---
window.showDetail = function(title, time, content, event) {
  const target = event.currentTarget;
  const scheduleId = target.getAttribute('data-id');
  const sheet = document.getElementById('bottom-sheet');
  
  if (!sheet) return;

  // すでに開いていて、かつ同じ予定をクリックしたなら閉じる
  if (sheet.classList.contains('show') && currentActiveId === scheduleId) {
    hideDetail();
  } else {
    // 中身を書き換えて表示
    document.getElementById('sheet-title').innerText = title;
    document.getElementById('sheet-time').innerText = time;
    
    const contentElement = document.getElementById('sheet-content');
    if (contentElement) {
      contentElement.innerText = content || "詳細な内容はありません。";
    }
    
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

// ---新規予定作成（タイムラインの背景クリック---
window.createNewSchedule = function(event) {
  if (event.target.closest('.swipe-content') || event.target.closest('.swipe-actions')) return;

  const timeline = document.getElementById('timeline');
  const displayDate = timeline.getAttribute('data-date'); 

  const rect = timeline.getBoundingClientRect();
  const y = event.clientY - rect.top;
  
  const hour = Math.floor(y / 60);
  const startHour = String(hour).padStart(2, '0');
  const endHour = String((hour + 1) % 24).padStart(2, '0');
  
  hideDetail();
  
  window.location.href = `/schedules/new?date=${displayDate}&start_time=${startHour}:00&end_time=${endHour}:00`;
};

// ---スワイプ処理の関数定義---
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
    content.style.transform = 'translateX(-100px)';
  } else if (change < -50) {
    content.style.transform = 'translateX(0)';
  }
};

const endSwipe = (e) => {
  const content = e.target.closest('.swipe-content');
  if (content) content.startX = undefined;
};

const setupTimePicker = () => {
  const timeInputs = document.querySelectorAll('.js-time-picker');
  timeInputs.forEach(input => {
    input.addEventListener('click', (e) => {
      try {
        e.target.showPicker();
      } catch (error) {
        e.target.focus();
      }
    });
  });
};

// ---イベントの登録---
document.addEventListener("mousedown", (e) => startSwipe(e));
document.addEventListener("mousemove", (e) => moveSwipe(e));
document.addEventListener("mouseup", (e) => endSwipe(e));

document.addEventListener("touchstart", (e) => startSwipe(e), { passive: true });
document.addEventListener("touchmove", (e) => moveSwipe(e), { passive: true });
document.addEventListener("touchend", (e) => endSwipe(e));

document.addEventListener("turbo:load", () => {
  setupTimePicker();
});