<template>
  <div class="triathlon-ui">
    <!-- Hàng 1: Thông tin chính -->
    <div class="main-row">
      <!-- Left: Phase Info -->
      <div class="phase-section">
        <div class="phase-icon">{{ phaseIcon }}</div>
        <div class="phase-name">{{ phaseName }}</div>
      </div>

      <!-- Center: Progress Info -->
      <div class="progress-section">
        <div class="stat-item">
          <span class="stat-label">CHECKPOINT</span>
          <span class="stat-value">{{ currentCheckpoint }}/{{ totalCheckpoints }}</span>
        </div>
        <div class="stat-divider"></div>
        <div class="stat-item">
          <span class="stat-label">THỜI GIAN</span>
          <span class="stat-value">{{ formattedTime }}</span>
        </div>
        <div class="stat-divider"></div>
        <div class="stat-item" :class="{ 'warning': remainingSeconds < 120 }">
          <span class="stat-label">CÒN LẠI</span>
          <span class="stat-value">{{ formattedRemaining }}</span>
        </div>
      </div>
    </div>

    <!-- Hàng 2: Controls -->
    <div class="controls-row">
      <div class="control-hint">
        <kbd>Y</kbd>
        <span>Quay lại checkpoint</span>
      </div>
      <div class="control-divider">|</div>
      <div class="control-hint">
        <kbd>/triathlon_cancel</kbd>
        <span>Thoát minigame</span>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'TriathlonUI',
  props: {
    phaseName: {
      type: String,
      required: true
    },
    phaseIcon: {
      type: String,
      required: true
    },
    currentCheckpoint: {
      type: Number,
      required: true
    },
    totalCheckpoints: {
      type: Number,
      required: true
    },
    timeSeconds: {
      type: Number,
      required: true
    },
    maxTimeSeconds: {
      type: Number,
      default: 600 // 10 phút
    }
  },
  setup(props) {
    const formattedTime = computed(() => {
      const minutes = Math.floor(props.timeSeconds / 60)
      const seconds = props.timeSeconds % 60
      return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    })

    const remainingSeconds = computed(() => {
      return Math.max(0, props.maxTimeSeconds - props.timeSeconds)
    })

    const formattedRemaining = computed(() => {
      const minutes = Math.floor(remainingSeconds.value / 60)
      const seconds = remainingSeconds.value % 60
      return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    })

    return {
      formattedTime,
      remainingSeconds,
      formattedRemaining
    }
  }
}
</script>

<style scoped>
.triathlon-ui {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Hàng 1: Main Row */
.main-row {
  display: flex;
  align-items: center;
  gap: 25px;
  background: linear-gradient(135deg, rgba(58, 57, 60, 0.85) 0%, rgba(45, 44, 47, 0.85) 100%);
  border-radius: 10px;
  padding: 12px 25px;
  border: 2px solid rgba(255, 190, 45, 0.4);
}

/* Phase Section (Left) */
.phase-section {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-right: 25px;
  border-right: 2px solid rgba(255, 190, 45, 0.3);
}

.phase-icon {
  font-size: 36px;
  filter: drop-shadow(0 2px 4px rgba(255, 215, 0, 0.3));
  line-height: 1;
}

.phase-name {
  font-size: 20px;
  font-weight: 700;
  color: #FFD700;
  text-transform: uppercase;
  letter-spacing: 1px;
  text-shadow: 0 2px 8px rgba(255, 215, 0, 0.4);
  white-space: nowrap;
}

/* Progress Section (Center) */
.progress-section {
  display: flex;
  align-items: center;
  gap: 20px;
  flex: 1;
}

.stat-item {
  display: flex;
  flex-direction: column;
  gap: 2px;
  transition: all 0.3s ease;
}

.stat-label {
  font-size: 10px;
  color: #aaaaaa;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 500;
}

.stat-value {
  font-size: 20px;
  font-weight: 700;
  color: #FFD700;
  text-shadow: 0 0 10px rgba(255, 215, 0, 0.5);
  font-family: 'Roboto Mono', monospace;
}

.stat-item.warning .stat-value {
  color: #ff6b6b;
  text-shadow: 0 0 10px rgba(255, 107, 107, 0.5);
  animation: warningPulse 1s ease-in-out infinite;
}

.stat-divider {
  width: 1px;
  height: 35px;
  background: rgba(255, 190, 45, 0.2);
}

@keyframes warningPulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

/* Hàng 2: Controls Row */
.controls-row {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 15px;
  background: linear-gradient(135deg, rgba(58, 57, 60, 0.75) 0%, rgba(45, 44, 47, 0.75) 100%);
  border-radius: 8px;
  padding: 8px 20px;
  border: 1px solid rgba(255, 190, 45, 0.25);
}

.control-hint {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #cccccc;
}

.control-divider {
  color: rgba(255, 190, 45, 0.4);
  font-size: 14px;
  font-weight: 300;
}

kbd {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  color: #1a1a1a;
  padding: 4px 10px;
  border-radius: 6px;
  font-family: 'Roboto Mono', monospace;
  font-weight: 700;
  font-size: 11px;
  box-shadow: 0 2px 8px rgba(255, 215, 0, 0.4);
  border: 1px solid rgba(255, 215, 0, 0.6);
  min-width: 24px;
  text-align: center;
}

/* Responsive */
@media (max-width: 1024px) {
  .main-row {
    gap: 15px;
    padding: 10px 20px;
  }

  .phase-section {
    padding-right: 15px;
  }

  .phase-icon {
    font-size: 30px;
  }

  .phase-name {
    font-size: 18px;
  }

  .stat-value {
    font-size: 18px;
  }
}

@media (max-width: 768px) {
  .main-row {
    flex-wrap: wrap;
    gap: 10px;
    padding: 10px 15px;
  }

  .phase-section {
    border: none;
    padding: 0;
  }

  .progress-section {
    width: 100%;
    justify-content: space-around;
    padding-top: 10px;
    border-top: 2px solid rgba(255, 190, 45, 0.3);
  }

  .stat-divider {
    height: 30px;
  }

  .controls-row {
    flex-direction: column;
    gap: 8px;
    padding: 6px 15px;
  }

  .control-divider {
    display: none;
  }
}
</style>
