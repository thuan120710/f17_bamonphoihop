<template>
  <div class="triathlon-container">
    <!-- Countdown Overlay (giữa màn hình) -->
    <transition name="countdown-fade">
      <div v-if="showCountdown" class="countdown-overlay">
        <div class="countdown-number">{{ countdownNumber }}</div>
        <div class="countdown-text">GET READY!</div>
      </div>
    </transition>

    <!-- Main UI -->
    <transition name="slide-fade">
      <TriathlonUI 
        v-show="isVisible"
        :phase-name="phaseName"
        :phase-icon="phaseIcon"
        :current-checkpoint="currentCheckpoint"
        :total-checkpoints="totalCheckpoints"
        :time-seconds="timeSeconds"
      />
    </transition>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import TriathlonUI from './components/TriathlonUI.vue'

export default {
  name: 'App',
  components: {
    TriathlonUI
  },
  setup() {
    const isVisible = ref(false) // Bật mặc định cho dev
    const showCountdown = ref(false)
    const countdownNumber = ref(5)
    const phaseName = ref('CHẠY BỘ')
    const phaseIcon = ref('🏃')
    const currentCheckpoint = ref(2)
    const totalCheckpoints = ref(5)
    const timeSeconds = ref(71) // 01:11

    const phaseConfig = {
      'run': { name: 'CHẠY BỘ', icon: '🏃' },
      'swim': { name: 'BƠI', icon: '🏊' },
      'bike': { name: 'ĐẠP XE', icon: '🚴' }
    }

    const playSound = (soundFile, volume = 0.5) => {
      const audio = new Audio(`./sounds/${soundFile}.mp3`)
      audio.volume = volume
      audio.play().catch(err => console.log('Audio play error:', err))
    }

    const updatePhase = (phase) => {
      if (phaseConfig[phase]) {
        phaseName.value = phaseConfig[phase].name
        phaseIcon.value = phaseConfig[phase].icon
      }
    }

    const startCountdown = (seconds) => {
      showCountdown.value = true
      countdownNumber.value = seconds

      const interval = setInterval(() => {
        countdownNumber.value--
        if (countdownNumber.value <= 0) {
          clearInterval(interval)
          setTimeout(() => {
            showCountdown.value = false
          }, 500)
        }
      }, 1000)
    }

    const handleMessage = (event) => {
      const data = event.data
      if (!data) return

      // Play sound (giống gameracing)
      if (data.transactionType === 'playSound') {
        playSound(data.transactionFile, data.transactionVolume || 0.5)
        return
      }

      // Countdown
      if (data.action === 'countdown') {
        startCountdown(data.seconds || 5)
        return
      }

      // Show UI
      if (data.action === 'show') {
        isVisible.value = true
        if (data.phase) updatePhase(data.phase)
        if (data.checkpoint !== undefined) currentCheckpoint.value = data.checkpoint
        if (data.totalCheckpoints !== undefined) totalCheckpoints.value = data.totalCheckpoints
        if (data.time !== undefined) timeSeconds.value = data.time
        return
      }
      
      // Hide UI
      if (data.action === 'hide') {
        isVisible.value = false
        return
      }

      // Update UI realtime (giống gameracing)
      if (data.action === 'update') {
        if (data.phase) updatePhase(data.phase)
        if (data.checkpoint !== undefined) currentCheckpoint.value = data.checkpoint
        if (data.totalCheckpoints !== undefined) totalCheckpoints.value = data.totalCheckpoints
        if (data.time !== undefined) timeSeconds.value = data.time
      }
    }

    onMounted(() => {
      window.addEventListener('message', handleMessage)
      console.log('F17 Triathlon UI - Vue 3 SFC Loaded')
      
    })

    return {
      isVisible,
      showCountdown,
      countdownNumber,
      phaseName,
      phaseIcon,
      currentCheckpoint,
      totalCheckpoints,
      timeSeconds
    }
  }
}
</script>

<style scoped>
.triathlon-container {
  width: 100%;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 3%;
  position: relative;
}

/* Countdown Overlay */
.countdown-overlay {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 9999;
  text-align: center;
}

.countdown-number {
  font-size: 180px;
  font-weight: 900;
  color: #FFD700;
  text-shadow: 
    0 0 20px rgba(255, 215, 0, 0.8),
    0 0 40px rgba(255, 215, 0, 0.6),
    0 0 60px rgba(255, 215, 0, 0.4),
    0 4px 8px rgba(0, 0, 0, 0.5);
  line-height: 1;
  animation: pulse 1s ease-in-out;
}

.countdown-text {
  font-size: 32px;
  font-weight: 700;
  color: #ffffff;
  text-transform: uppercase;
  letter-spacing: 8px;
  margin-top: 20px;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
  animation: fadeInUp 0.5s ease-out;
}

@keyframes pulse {
  0% {
    transform: scale(0.5);
    opacity: 0;
  }
  50% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.countdown-fade-enter-active,
.countdown-fade-leave-active {
  transition: opacity 0.5s ease;
}

.countdown-fade-enter-from,
.countdown-fade-leave-to {
  opacity: 0;
}

.slide-fade-enter-active {
  transition: all 0.5s ease-out;
}

.slide-fade-leave-active {
  transition: all 0.3s ease-in;
}

.slide-fade-enter-from {
  opacity: 0;
  transform: translateY(-30px);
}

.slide-fade-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}
</style>
