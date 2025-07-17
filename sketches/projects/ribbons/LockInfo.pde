class LockInfo {
    int particleIndex;
    float lockTime;
    float decayRate;
    float unlockTime;
    float cooldown;

    LockInfo(int particleIndex, float lockTime, float decayRate, float cooldown) {
        this.particleIndex = particleIndex;
        this.lockTime = lockTime;
        this.decayRate = decayRate;
        this.cooldown = cooldown;
        this.unlockTime = -1; // Initialize unlock time as -1 to indicate it hasn't been unlocked yet
    }
}
