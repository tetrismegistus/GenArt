class Thread {
    ArrayList<Particle> particles;
    ArrayList<Spring> springs;
    float strength;
    String displayString;
    int numLets;
    color c;
    ArrayList<LockInfo> locks; // To store lock information

    Thread(float x1, float y1, float x2, float y2, float resolution, color c, float strength, String word) {
        particles = new ArrayList<Particle>();
        springs = new ArrayList<Spring>();
        this.strength = strength;
        this.displayString = word;
        this.numLets = word.length();
        this.c = c;
        this.locks = new ArrayList<LockInfo>(); // Initialize locks list

        for (int i = 0; i < resolution; i++) {
            float x = lerp(x1, x2, i / resolution);
            float y = lerp(y1, y2, i / resolution);
            Particle p = new Particle(x, y);
            particles.add(p);
            physics.addParticle(p);
        }

        for (int i = 0; i < particles.size() - 1; i++) {
            Particle a = particles.get(i);
            Particle b = particles.get(i + 1);
            Spring s = new Spring(a, b, c, strength);
            springs.add(s);
            physics.addSpring(s);
        }
    }

    void display() {
        if (displayString.length() == 0) {
            return; // Skip drawing if the string is empty
        }
        fill(c);
        int step = particles.size() / numLets; // Updated to ensure proper spacing
        int stringLength = displayString.length();
        for (Spring s : springs) {
            s.display();
        }
        for (int i = 0; i < numLets; i++) {
            int index = i * step;
            if (index >= particles.size()) {
                break; // Ensure we don't go out of bounds
            }
            Particle a = particles.get(index);
            
            // Get the next letter from the string
            char letter = displayString.charAt(i % stringLength);

            float angle = 0;
            if (index > 0 && index < particles.size() - 1) {
                Particle prev = particles.get(index - 1);
                Particle next = particles.get(index + 1);
                angle = atan2(next.y - prev.y, next.x - prev.x);
            }

            // Stabilize angle for locked particles
            if (a.isLocked()) {
                angle *= 0.1; // Reduce rotation angle for locked particles
            }
            
            float velocityMagnitude = a.getVelocity().magnitude(); // Example for velocity
            int fontIndex = (int) map(velocityMagnitude, 0, 10, 0, numFonts - 1);
            fontIndex = constrain(fontIndex, 0, numFonts - 1); // Ensure index is within bounds
            textFont(fonts.get(fontIndex));

            pushMatrix();
            translate(a.x, a.y);
            rotate(angle);

            text(letter, 0, 0);
            popMatrix();
        }
    }

    void lockParticle(int idx) {
        Particle particle = particles.get(idx);
        boolean canLock = true;

        // Check if the particle is already locked
        for (LockInfo lock : locks) {
            if (lock.particleIndex == idx) {
                canLock = false;
                break;
            }
        }

        // Check if the particle can be relocked after cooldown
        if (!canLock) {
            float currentTime = millis();
            for (LockInfo lock : locks) {
                if (lock.particleIndex == idx && (currentTime - lock.unlockTime < lock.cooldown)) {
                    canLock = false;
                    break;
                }
            }
        }

        if (canLock && !particle.isLocked()) {
            particle.lock();
            particle.clearVelocity(); // Clear velocity when locking
            locks.add(new LockInfo(idx, millis(), lockDecay, 2000)); // Add lock info with a decay rate and a cooldown of 2 seconds
        }
    }

    void updateLocks() {
        float currentTime = millis();
        
        for (int i = locks.size() - 1; i >= 0; i--) {
            LockInfo lockInfo = locks.get(i);
            if (currentTime - lockInfo.lockTime > lockInfo.decayRate) {
                Particle particle = particles.get(lockInfo.particleIndex);
                particle.unlock();
                particle.clearVelocity(); // Clear velocity when unlocking
                lockInfo.unlockTime = currentTime; // Update unlock time
                locks.remove(i); // Remove expired lock

                // Create a new thread if the thread count is below the threshold
                if (threads.size() < numThreads) {
                    float y = random(height);
                    float x = -600;
                    int cIdx = (int) random(p.length);
                    String word = getNextWord(); // Get the next word from the list
                    float sz = word.length() * 10;
                    createAndLockThread(x, y, x + sz / 2, y + sz, p[cIdx], springStrength, word);
                }
            } else {
                // Clear velocity and reset forces for locked particles
                particles.get(lockInfo.particleIndex).clearVelocity();
            }
        }
    }

    void applyWindForce(Vec2D wind, float directForceScale, float constantForce) {
        for (int i = 1; i < particles.size(); i++) {
            Particle p = particles.get(i);
            Particle prevP = particles.get(i - 1); // Get the previous particle

            // Calculate the direction vector as the difference between the current and previous particles
            Vec2D dir = p.sub(prevP);

            // Compute the normal vector to the direction vector
            Vec2D norm = new Vec2D(dir.y, -dir.x).normalize();

            // Calculate the wind scale factor
            float windScale = Math.abs(wind.dot(norm)) * directForceScale + constantForce;

            // Reduce wind force for locked particles
            if (p.isLocked()) {
                windScale *= 0.1; // Reduce wind influence by 90% for locked particles
            }

            // Adjust the wind force based on the calculated scale
            Vec2D adjustedWind = wind.scale(windScale);

            // Apply the adjusted wind force to the particle
            p.addForce(adjustedWind);
        }
    }

    void applyDamping(float damping) {
        for (Particle p : particles) {
            Vec2D velocity = p.getVelocity();
            Vec2D dampingForce = velocity.scale(-damping);
            p.addForce(dampingForce);
        }
    }

    boolean isOffScreen() {
        for (Particle p : particles) {
            if (p.x <= width && p.y >= 0 && p.y <= height) {
                return false; // If any particle is on-screen, the thread is not off-screen
            }
        }
        return true; // All particles are off-screen
    }
}
