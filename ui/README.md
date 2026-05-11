# F17 Triathlon UI - Vue 3 SFC

## Cài đặt

```bash
cd ui
npm install
```

## Build cho Production

```bash
npm run build
```

**Lưu ý:** Script sẽ tự động copy file âm thanh từ `f17_gameracing/html/sounds/` trước khi build!

Build sẽ tạo file vào thư mục `../html/` bao gồm:
- `index.html`
- `app.js`
- `assets/` (CSS, JS)
- `sounds/` (5count.mp3, rightchose.mp3) ✅ Tự động copy

## Development

```bash
npm run dev
```

## Cấu trúc

```
ui/
├── public/
│   └── sounds/              # File âm thanh (tự động copy từ gameracing)
│       ├── 5count.mp3
│       └── rightchose.mp3
├── src/
│   ├── components/
│   │   └── TriathlonUI.vue  # Component UI chính
│   ├── App.vue              # Root component
│   ├── main.js              # Entry point
│   └── style.css            # Global styles
├── scripts/
│   └── copy-sounds.js       # Script tự động copy âm thanh
├── index.html               # HTML template
├── package.json             # Dependencies
└── vite.config.js           # Vite config
```

## Tính năng

- ✅ Vue 3 Single File Component (.vue)
- ✅ Reactive UI với tông màu vàng
- ✅ Hệ thống âm thanh giống gameracing (tự động copy)
- ✅ Update realtime (checkpoint, timer)
- ✅ Transition animations
- ✅ Responsive design

## Workflow

1. `npm install` - Cài đặt dependencies
2. `npm run build` - Build production
   - Tự động chạy `copy-sounds` trước khi build
   - Copy file âm thanh từ gameracing
   - Build Vue app
   - Output vào `../html/`
3. Restart resource trong game

## Sử dụng trong game

UI sẽ tự động hiển thị khi bắt đầu race và update realtime:
- Countdown 5 giây với âm thanh `5count.mp3`
- Qua checkpoint phát âm thanh `rightchose.mp3`
- Hiển thị phase hiện tại (Chạy bộ/Bơi/Đạp xe)
- Hiển thị checkpoint và thời gian realtime
