<template>
  <div class="triathlon-ui">
    <!-- Phase Info -->
    <div class="phase-info">
      <div class="phase-name">{{ phaseName }}</div>
      <div class="phase-icon">{{ phaseIcon }}</div>
    </div>

    <!-- Progress Info -->
    <div class="progress-info">
      <div class="checkpoint-text">
        Checkpoint <span class="highlight">{{ currentCheckpoint }}</span>/<span class="highlight">{{ totalCheckpoints }}</span>
      </div>
      <div class="timer-text">
        Thời gian <span class="highlight">{{ formattedTime }}</span>
      </div>
      <div class="remaining-text" :class="{ 'warning': remainingSeconds < 120 }">
        Còn lại <span class="highlight-remaining">{{ formattedRemaining }}</span>
      </div>
    </div>

    <!-- Controls Info -->
    <div class="controls-info">
      <span class="control-item">
        <kbd>Y</kbd> Quay lại checkpoint
      </span>
      <span class="divider">|</span>
      <span class="control-item">
        <kbd>/triathlon_cancel</kbd> Thoát
      </span>
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
  background: linear-gradient(135deg, rgba(58, 57, 60, 0.95) 0%, rgba(45, 44, 47, 0.95) 100%);
  border-radius: 12px;
  padding: 20px 30px;
  min-width: 450px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
  border: 2px solid rgba(255, 190, 45, 0.3);
}

/* Phase Info */
.phase-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 2px solid rgba(255, 190, 45, 0.2);
}

.phase-name {
  font-size: 24px;
  font-weight: 700;
  color: #FFD700;
  text-transform: uppercase;
  letter-spacing: 1px;
  text-shadow: 0 2px 8px rgba(255, 215, 0, 0.4);
}

.phase-icon {
  font-size: 32px;
  filter: drop-shadow(0 2px 4px rgba(255, 215, 0, 0.3));
}

/* Progress Info */
.progress-info {
  margin-bottom: 15px;
}

.checkpoint-text,
.timer-text,
.remaining-text {
  font-size: 18px;
  color: #ffffff;
  margin-bottom: 8px;
  font-weight: 500;
}

.remaining-text {
  font-size: 16px;
  transition: all 0.3s ease;
}

.remaining-text.warning {
  color: #ff6b6b;
  animation: warningPulse 1s ease-in-out infinite;
}

@keyframes warningPulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

.highlight {
  color: #FFD700;
  font-weight: 700;
  text-shadow: 0 0 10px rgba(255, 215, 0, 0.5);
}

.highlight-remaining {
  color: #4CAF50;
  font-weight: 700;
  text-shadow: 0 0 10px rgba(76, 175, 80, 0.5);
}

.warning .highlight-remaining {
  color: #ff6b6b;
  text-shadow: 0 0 10px rgba(255, 107, 107, 0.5);
}

/* Controls Info */
.controls-info {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
  padding-top: 15px;
  border-top: 2px solid rgba(255, 190, 45, 0.2);
  font-size: 14px;
  color: #cccccc;
}

.control-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

kbd {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  color: #1a1a1a;
  padding: 4px 10px;
  border-radius: 6px;
  font-family: 'Roboto', monospace;
  font-weight: 700;
  font-size: 13px;
  box-shadow: 0 2px 8px rgba(255, 215, 0, 0.4);
  border: 1px solid rgba(255, 215, 0, 0.6);
}

.divider {
  color: rgba(255, 190, 45, 0.5);
  font-weight: 300;
}

/* Responsive */
@media (max-width: 768px) {
  .triathlon-ui {
    min-width: 90%;
    padding: 15px 20px;
  }

  .phase-name {
    font-size: 20px;
  }

  .phase-icon {
    font-size: 28px;
  }

  .checkpoint-text,
  .timer-text {
    font-size: 16px;
  }

  .controls-info {
    flex-direction: column;
    gap: 8px;
  }

  .divider {
    display: none;
  }
}
</style>
