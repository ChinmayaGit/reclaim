import 'resource_model.dart';

/// All curated resource content — articles, audio guides, worksheets, and
/// videos — baked into the app so they work offline and without a seeded
/// Firestore collection.
class ResourcesData {
  static const List<ResourceItem> all = [
    // ──────────────────────── ARTICLES ───────────────────────────────────

    ResourceItem(
      id: 'article_halt',
      title: 'The HALT Method',
      description: 'Managing urges with this simple but powerful framework.',
      emoji: '✋',
      type: 'article',
      categories: ['addiction', 'stress'],
      isPremium: false,
      duration: '4 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'When a craving or urge hits, it can feel overwhelming and impossible '
          'to resist. The HALT method gives you four questions to check before '
          'acting on any urge — because often the urge isn\'t really about the '
          'substance or behaviour at all.'),
        ContentSection(type: 'heading', content: 'H — Hungry'),
        ContentSection(type: 'paragraph', content:
          'Low blood sugar affects your mood, patience, and decision-making '
          'before you even notice it. Ask yourself: When did I last eat? Drink '
          'a glass of water and have a small snack before doing anything else.'),
        ContentSection(type: 'heading', content: 'A — Angry'),
        ContentSection(type: 'paragraph', content:
          'Anger and resentment are among the top relapse triggers. If you\'re '
          'angry, identify the source. Is it something that can be resolved now? '
          'If not, write it down, then do something physical — a walk, stretching, '
          'cold water on your face.'),
        ContentSection(type: 'heading', content: 'L — Lonely'),
        ContentSection(type: 'paragraph', content:
          'Loneliness doesn\'t always mean being alone — you can feel lonely in '
          'a crowded room. Reach out to one safe person right now. A text, a '
          'call, or even joining a public space can shift the feeling.'),
        ContentSection(type: 'heading', content: 'T — Tired'),
        ContentSection(type: 'paragraph', content:
          'Fatigue strips away your resilience. If you\'re exhausted, your '
          'willpower is already depleted. Rest is not weakness — it is recovery. '
          'A 20-minute rest or even lying down can reset your capacity to cope.'),
        ContentSection(type: 'tip', content:
          'Keep a HALT card in your phone case or wallet. Every time you feel '
          'an urge, pull it out and check all four before acting.'),
        ContentSection(type: 'heading', content: 'Using HALT Daily'),
        ContentSection(type: 'paragraph', content:
          'You don\'t have to wait for a crisis. Check in with HALT every morning '
          'and every evening. Make it a habit. Over time you\'ll start catching '
          'the early warning signs before they become urges.'),
        ContentSection(type: 'quote', content:
          '"Between stimulus and response there is a space. In that space lies '
          'our freedom." — Viktor Frankl'),
      ],
    ),

    ResourceItem(
      id: 'article_triggers',
      title: 'Understanding Your Triggers',
      description: 'Learn to identify what triggers urges and how to respond mindfully.',
      emoji: '📖',
      type: 'article',
      categories: ['addiction', 'trauma', 'stress'],
      isPremium: false,
      duration: '5 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'A trigger is any person, place, thing, emotion, or situation that '
          'activates a craving or urge. Triggers are not your enemy — they are '
          'data. When you understand your triggers, you gain power over them.'),
        ContentSection(type: 'heading', content: 'Types of Triggers'),
        ContentSection(type: 'bullet', content:
          'External — places you used to go, people you used with, events like '
          'parties, or even driving past a certain street.'),
        ContentSection(type: 'bullet', content:
          'Emotional — feeling bored, anxious, celebratory, sad, or stressed.'),
        ContentSection(type: 'bullet', content:
          'Physical — pain, hunger, fatigue, illness.'),
        ContentSection(type: 'bullet', content:
          'Social — conflict with family, relationship stress, peer pressure.'),
        ContentSection(type: 'heading', content: 'How to Identify Yours'),
        ContentSection(type: 'paragraph', content:
          'For two weeks, each time you notice an urge, write it down immediately: '
          'what were you doing, where were you, who were you with, and what were '
          'you feeling? Patterns will emerge. These patterns are your personal '
          'trigger map.'),
        ContentSection(type: 'heading', content: 'The STOP Technique'),
        ContentSection(type: 'bullet', content: 'S — Stop what you are doing.'),
        ContentSection(type: 'bullet', content: 'T — Take a breath.'),
        ContentSection(type: 'bullet', content: 'O — Observe what\'s happening inside you without judging it.'),
        ContentSection(type: 'bullet', content: 'P — Proceed with awareness, not autopilot.'),
        ContentSection(type: 'tip', content:
          'Your journal is the best trigger-mapping tool you have. After each '
          'entry, tag the emotions you felt. Over weeks, patterns become clear.'),
        ContentSection(type: 'heading', content: 'Building Your Response Plan'),
        ContentSection(type: 'paragraph', content:
          'For each of your top three triggers, write down: (1) Early warning '
          'signs, (2) One coping action you\'ll take immediately, (3) One person '
          'you\'ll contact. Having a plan before the trigger hits makes you '
          'exponentially more likely to use it.'),
        ContentSection(type: 'quote', content:
          '"Name it to tame it." — Dr. Dan Siegel'),
      ],
    ),

    ResourceItem(
      id: 'article_habit_science',
      title: 'The Science of Habit Breaking',
      description: 'How neural pathways form and how to rewire them for recovery.',
      emoji: '🧠',
      type: 'article',
      categories: ['addiction', 'stress'],
      isPremium: false,
      duration: '8 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'Every behaviour you\'ve ever repeated has carved a neural pathway in '
          'your brain. The more you repeat it, the deeper and faster that pathway '
          'becomes. This is not a flaw — it\'s how the brain conserves energy. '
          'But it also means that "just stop" is never enough.'),
        ContentSection(type: 'heading', content: 'The Habit Loop'),
        ContentSection(type: 'paragraph', content:
          'Neuroscientist Ann Graybiel\'s research shows that every habit has '
          'three components: a cue (trigger), a routine (the behaviour), and a '
          'reward (what the brain gets). To change a habit, you must keep the '
          'same cue and reward but replace the routine.'),
        ContentSection(type: 'tip', content:
          'Example: Craving (cue) → drink alcohol (routine) → numbing of stress '
          '(reward). Replacement: Craving → 5-minute breathing exercise → '
          'physical calm (same reward, different path).'),
        ContentSection(type: 'heading', content: 'Neuroplasticity Is on Your Side'),
        ContentSection(type: 'paragraph', content:
          'The brain can physically rewire itself at any age. Every time you '
          'resist an urge, you weaken the old pathway and strengthen the new one. '
          'The first 90 days are the hardest because the old pathway is still '
          'dominant — but it does fade with disuse.'),
        ContentSection(type: 'heading', content: 'The 21-Day Myth'),
        ContentSection(type: 'paragraph', content:
          'You may have heard habits form in 21 days. Research by Phillippa Lally '
          'at UCL found the actual average is 66 days — ranging from 18 to 254 '
          'days depending on the habit and the person. Give yourself grace. You '
          'are doing something biologically difficult.'),
        ContentSection(type: 'heading', content: 'Dopamine and Recovery'),
        ContentSection(type: 'paragraph', content:
          'Substances and addictive behaviours flood the brain\'s reward system '
          'with dopamine — up to 10x more than natural rewards. This is why '
          'ordinary pleasures feel flat early in recovery. It takes time for '
          'dopamine receptors to normalize. Small wins — a good meal, a sunset, '
          'a conversation — gradually rebuild natural reward sensitivity.'),
        ContentSection(type: 'quote', content:
          '"You don\'t rise to the level of your goals. You fall to the level '
          'of your systems." — James Clear, Atomic Habits'),
      ],
    ),

    ResourceItem(
      id: 'article_emotion_reg',
      title: 'Emotional Regulation Techniques',
      description: 'Practical strategies for managing overwhelming emotions.',
      emoji: '💭',
      type: 'article',
      categories: ['trauma', 'stress', 'breakup'],
      isPremium: false,
      duration: '6 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'Emotional dysregulation — feeling overwhelmed, reactive, or unable '
          'to calm down — is one of the most common challenges in recovery. '
          'The good news: regulation is a skill, and skills can be practised.'),
        ContentSection(type: 'heading', content: 'The 90-Second Rule'),
        ContentSection(type: 'paragraph', content:
          'Neuroscientist Jill Bolte Taylor discovered that the physiological '
          'response to an emotion — the hormonal surge — lasts just 90 seconds. '
          'If you can ride those 90 seconds without acting, the wave passes. '
          'What keeps emotions going beyond 90 seconds is your thoughts about '
          'the emotion. Notice this next time you feel flooded.'),
        ContentSection(type: 'heading', content: 'TIPP Skills (from DBT)'),
        ContentSection(type: 'bullet', content:
          'T — Temperature: Splash cold water on your face or hold ice. Cold '
          'activates the dive reflex and rapidly slows your heart rate.'),
        ContentSection(type: 'bullet', content:
          'I — Intense exercise: 20 jumping jacks, a sprint, or push-ups burn '
          'off adrenaline and shift your body state.'),
        ContentSection(type: 'bullet', content:
          'P — Paced breathing: Slow your exhale to longer than your inhale '
          '(e.g., in for 4, out for 7). This activates the parasympathetic '
          'nervous system.'),
        ContentSection(type: 'bullet', content:
          'P — Progressive relaxation: Tense each muscle group for 5 seconds, '
          'then release. Work from feet to face.'),
        ContentSection(type: 'heading', content: 'Opposite Action'),
        ContentSection(type: 'paragraph', content:
          'When an emotion is telling you to do one thing, try doing the '
          'opposite. Shame says hide — so reach out. Fear says freeze — so '
          'take one small step. Sadness says withdraw — so do something active. '
          'This isn\'t suppression — it\'s retraining the emotional response.'),
        ContentSection(type: 'tip', content:
          'Keep a list of three activities that reliably shift your mood — a '
          'walk, a shower, a specific song. Use them before reaching for '
          'unhealthy coping mechanisms.'),
        ContentSection(type: 'quote', content:
          '"You can\'t stop the waves, but you can learn to surf." — Jon Kabat-Zinn'),
      ],
    ),

    ResourceItem(
      id: 'article_self_worth',
      title: 'Rebuilding Self-Worth After Heartbreak',
      description: 'A guided path to rediscovering your identity and value.',
      emoji: '💝',
      type: 'article',
      categories: ['breakup'],
      isPremium: true,
      duration: '12 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'When a significant relationship ends, it can feel like you\'ve lost '
          'not just a person but a version of yourself. Your identity was partly '
          'built around the relationship — shared plans, a shared social world, '
          'a sense of being chosen. Rebuilding after this loss is real grief work.'),
        ContentSection(type: 'heading', content: 'What You Actually Lost'),
        ContentSection(type: 'paragraph', content:
          'Beyond the person, you may have lost: a vision of your future, a '
          'daily routine, social connections, a sense of security, and aspects '
          'of yourself that only existed in that relationship. Grieving all of '
          'these — not just the person — is part of the process.'),
        ContentSection(type: 'heading', content: 'The Self-Worth Trap'),
        ContentSection(type: 'paragraph', content:
          'Many people unconsciously link their worth to being chosen by someone '
          'else. When rejected, this translates to "I am not enough." This is '
          'not a fact — it\'s an emotional conclusion drawn from pain. Your '
          'worth existed before the relationship and exists independently of it.'),
        ContentSection(type: 'heading', content: 'Practical Steps'),
        ContentSection(type: 'bullet', content:
          'Write a list of 10 qualities you had before this relationship. Read '
          'it daily for two weeks.'),
        ContentSection(type: 'bullet', content:
          'Reconnect with one interest or hobby you set aside during the relationship.'),
        ContentSection(type: 'bullet', content:
          'Identify one relationship (friend, family) you want to invest in.'),
        ContentSection(type: 'bullet', content:
          'Set one small, achievable goal unrelated to romance and pursue it.'),
        ContentSection(type: 'heading', content: 'On Moving Forward'),
        ContentSection(type: 'paragraph', content:
          'Moving forward does not mean forgetting or not caring. It means '
          'expanding again — letting new things, people, and experiences back '
          'into the space that grief has been occupying. You don\'t have to '
          'rush this. But you are allowed to step into it.'),
        ContentSection(type: 'quote', content:
          '"The most important relationship in your life is the one you have '
          'with yourself." — Diane Von Furstenberg'),
      ],
    ),

    ResourceItem(
      id: 'article_trauma_selfcare',
      title: 'Trauma-Informed Self Care',
      description: 'Evidence-based self-care practices for trauma survivors.',
      emoji: '🌱',
      type: 'article',
      categories: ['trauma'],
      isPremium: true,
      duration: '10 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'Trauma changes the nervous system. After traumatic experiences, the '
          'body can get stuck in a state of hypervigilance (always on alert) or '
          'shutdown (numbness, disconnection). Self-care for trauma survivors '
          'must work with the body, not just the mind.'),
        ContentSection(type: 'heading', content: 'Safety First'),
        ContentSection(type: 'paragraph', content:
          'Before anything else, you need to feel physically safe. This means '
          'your environment, your relationships, and your body. If you are not '
          'safe right now, that is the only priority.'),
        ContentSection(type: 'heading', content: 'Somatic (Body-Based) Practices'),
        ContentSection(type: 'bullet', content:
          'Grounding: feet flat on the floor, feel the weight of your body, '
          'name 5 things you can see. This anchors you in the present.'),
        ContentSection(type: 'bullet', content:
          'Shaking: animals in the wild shake after a stressful event to '
          'discharge adrenaline. You can do this intentionally — shake your '
          'hands, arms, and legs for 2 minutes.'),
        ContentSection(type: 'bullet', content:
          'Cold water: splashing cold water on your face activates the '
          'parasympathetic nervous system within seconds.'),
        ContentSection(type: 'heading', content: 'What NOT to Do'),
        ContentSection(type: 'paragraph', content:
          'Pushing yourself to "get over it" or "just move on" can retraumatize. '
          'Avoid numbing behaviours (alcohol, overworking, isolation) even when '
          'they feel like relief — they delay healing and often intensify symptoms.'),
        ContentSection(type: 'tip', content:
          'Healing from trauma is not linear. Bad days do not erase good days. '
          'Two steps forward, one step back is still forward.'),
        ContentSection(type: 'quote', content:
          '"The body keeps the score." — Bessel van der Kolk'),
      ],
    ),

    // ─────────────────────── AUDIO GUIDES ────────────────────────────────

    ResourceItem(
      id: 'audio_box_breathing',
      title: '5-Minute Breathing Calm',
      description: 'Guided box breathing to reduce anxiety in moments of crisis.',
      emoji: '🎧',
      type: 'audio',
      categories: ['addiction', 'stress', 'trauma'],
      isPremium: false,
      duration: '5 min',
      steps: [
        GuideStep(
          instruction: 'Find a comfortable position. Sit upright or lie down. '
              'Rest your hands on your lap or at your sides.',
          durationSeconds: 15,
          cue: 'Get comfortable...',
        ),
        GuideStep(
          instruction: 'Close your eyes or soften your gaze. Take one natural breath '
              'and let it go. Just settling in.',
          durationSeconds: 10,
          cue: 'Relax...',
        ),
        GuideStep(
          instruction: 'Breathe IN slowly through your nose for 4 counts.',
          durationSeconds: 4,
          cue: 'Breathe in... 1... 2... 3... 4',
        ),
        GuideStep(
          instruction: 'HOLD your breath gently. Lungs full. No tension.',
          durationSeconds: 4,
          cue: 'Hold... 1... 2... 3... 4',
        ),
        GuideStep(
          instruction: 'Breathe OUT slowly through your mouth for 4 counts.',
          durationSeconds: 4,
          cue: 'Breathe out... 1... 2... 3... 4',
        ),
        GuideStep(
          instruction: 'HOLD with empty lungs. Pause.',
          durationSeconds: 4,
          cue: 'Hold... 1... 2... 3... 4',
        ),
        GuideStep(
          instruction: 'Breathe IN again for 4 counts.',
          durationSeconds: 4,
          cue: 'Breathe in... 1... 2... 3... 4',
        ),
        GuideStep(
          instruction: 'HOLD.',
          durationSeconds: 4,
          cue: 'Hold...',
        ),
        GuideStep(
          instruction: 'Breathe OUT for 4 counts. Let go of any tension.',
          durationSeconds: 4,
          cue: 'Breathe out...',
        ),
        GuideStep(
          instruction: 'HOLD. Pause in the stillness.',
          durationSeconds: 4,
          cue: 'Hold...',
        ),
        GuideStep(
          instruction: 'One more full cycle. Breathe IN for 4.',
          durationSeconds: 4,
          cue: 'Breathe in...',
        ),
        GuideStep(
          instruction: 'HOLD.',
          durationSeconds: 4,
          cue: 'Hold...',
        ),
        GuideStep(
          instruction: 'Breathe OUT. Let everything go.',
          durationSeconds: 4,
          cue: 'Breathe out...',
        ),
        GuideStep(
          instruction: 'HOLD.',
          durationSeconds: 4,
          cue: 'Hold...',
        ),
        GuideStep(
          instruction: 'Return to natural breathing. Notice how you feel. '
              'Calmer? More centred? That\'s your nervous system resetting.',
          durationSeconds: 20,
          cue: 'Notice the calm...',
        ),
        GuideStep(
          instruction: 'When you\'re ready, slowly open your eyes. '
              'You did it. Well done.',
          durationSeconds: 10,
          cue: 'Complete.',
        ),
      ],
    ),

    ResourceItem(
      id: 'audio_grounding',
      title: 'Morning Grounding Meditation',
      description: 'Start your day with clarity using the 5-4-3-2-1 technique.',
      emoji: '🌅',
      type: 'audio',
      categories: ['trauma', 'stress', 'breakup'],
      isPremium: false,
      duration: '10 min',
      steps: [
        GuideStep(
          instruction: 'Good morning. Before reaching for your phone or starting '
              'your day, take 3 slow, deep breaths.',
          durationSeconds: 20,
          cue: 'Three deep breaths...',
        ),
        GuideStep(
          instruction: 'Open your eyes and look around the room. '
              'NAME 5 things you can SEE. Say them quietly or in your mind.',
          durationSeconds: 30,
          cue: 'I can see...',
        ),
        GuideStep(
          instruction: 'Now touch something near you. Name 4 things you can TOUCH '
              'or feel right now — the sheets, the air temperature, the floor, your own hands.',
          durationSeconds: 25,
          cue: 'I can feel...',
        ),
        GuideStep(
          instruction: 'Listen. Name 3 things you can HEAR — traffic, birds, '
              'the house settling, your own breathing.',
          durationSeconds: 20,
          cue: 'I can hear...',
        ),
        GuideStep(
          instruction: 'Name 2 things you can SMELL — your pillow, morning air, '
              'coffee, soap. Even if it\'s faint.',
          durationSeconds: 15,
          cue: 'I can smell...',
        ),
        GuideStep(
          instruction: 'Name 1 thing you can TASTE right now.',
          durationSeconds: 10,
          cue: 'I can taste...',
        ),
        GuideStep(
          instruction: 'You are here. You are present. You are safe. '
              'Take a moment to set one intention for today. Just one.',
          durationSeconds: 30,
          cue: 'My intention today is...',
        ),
        GuideStep(
          instruction: 'Repeat after me: "I am still here. I am still trying. '
              'That is enough."',
          durationSeconds: 15,
          cue: 'Say it. Mean it.',
        ),
        GuideStep(
          instruction: 'Your day begins now. Carry this calm with you.',
          durationSeconds: 10,
          cue: 'Complete.',
        ),
      ],
    ),

    ResourceItem(
      id: 'audio_body_scan',
      title: 'Body Scan Relaxation',
      description: 'Progressive muscle relaxation for sleep and stress.',
      emoji: '😌',
      type: 'audio',
      categories: ['stress', 'trauma'],
      isPremium: false,
      duration: '15 min',
      steps: [
        GuideStep(
          instruction: 'Lie down comfortably. Allow your body to sink into the '
              'surface beneath you. Close your eyes.',
          durationSeconds: 20,
          cue: 'Settling in...',
        ),
        GuideStep(
          instruction: 'Take three deep breaths. With each exhale, let go of '
              'the day behind you.',
          durationSeconds: 20,
          cue: 'Let go...',
        ),
        GuideStep(
          instruction: 'Bring your attention to your FEET. Scrunch your toes '
              'tightly for 5 seconds... then release completely.',
          durationSeconds: 10,
          cue: 'Tense... and release.',
        ),
        GuideStep(
          instruction: 'Move attention to your CALVES and SHINS. Flex them '
              'gently for 5 seconds... then let go. Feel the warmth.',
          durationSeconds: 10,
          cue: 'Tense... and release.',
        ),
        GuideStep(
          instruction: 'THIGHS and GLUTES. Squeeze tight for 5 seconds... '
              'then soften completely.',
          durationSeconds: 10,
          cue: 'Tense... and release.',
        ),
        GuideStep(
          instruction: 'Your BELLY. Take a full breath in, expand it... '
              'then exhale and let your belly soften.',
          durationSeconds: 12,
          cue: 'Breathe... and soften.',
        ),
        GuideStep(
          instruction: 'CHEST and BACK. Take a deep breath and hold your '
              'chest open for 5 seconds... then exhale fully.',
          durationSeconds: 10,
          cue: 'Open... and release.',
        ),
        GuideStep(
          instruction: 'HANDS and ARMS. Make fists, squeeze tight... '
              'then open your hands and let them go limp.',
          durationSeconds: 10,
          cue: 'Squeeze... and release.',
        ),
        GuideStep(
          instruction: 'SHOULDERS. Lift them up to your ears... '
              'hold the tension... then drop them completely.',
          durationSeconds: 10,
          cue: 'Up... and drop.',
        ),
        GuideStep(
          instruction: 'FACE. Scrunch your face tightly — eyes, nose, jaw... '
              'then soften every muscle in your face.',
          durationSeconds: 10,
          cue: 'Scrunch... and soften.',
        ),
        GuideStep(
          instruction: 'Your whole body is now soft and heavy. Breathe gently. '
              'If your mind wanders, bring it back to the weight of your body.',
          durationSeconds: 30,
          cue: 'Rest here...',
        ),
        GuideStep(
          instruction: 'Remain here as long as you need. When ready, wiggle '
              'your fingers and toes. Open your eyes slowly. You are rested.',
          durationSeconds: 20,
          cue: 'Complete.',
        ),
      ],
    ),

    ResourceItem(
      id: 'audio_urge_surfing',
      title: 'Craving Surfing Technique',
      description: 'Ride out urges without acting on them.',
      emoji: '🏄',
      type: 'audio',
      categories: ['addiction'],
      isPremium: true,
      duration: '8 min',
      steps: [
        GuideStep(
          instruction: 'Notice you are having a craving. Don\'t push it away — '
              'just acknowledge it. "I notice I am having an urge."',
          durationSeconds: 15,
          cue: 'Just notice it.',
        ),
        GuideStep(
          instruction: 'Take a slow breath and imagine yourself standing at '
              'the ocean\'s edge. The urge is a wave building offshore.',
          durationSeconds: 15,
          cue: 'See the wave...',
        ),
        GuideStep(
          instruction: 'Where do you feel the urge in your body? Your chest? '
              'Your gut? Your throat? Put your hand there.',
          durationSeconds: 20,
          cue: 'Locate it in your body.',
        ),
        GuideStep(
          instruction: 'Describe the sensation without judgment. Hot or cold? '
              'Tight or loose? Sharp or dull? Moving or still?',
          durationSeconds: 20,
          cue: 'Describe it...',
        ),
        GuideStep(
          instruction: 'Watch the wave grow. The craving is peaking now. '
              'This is the hardest part. Breathe slowly. You are riding it, not fighting it.',
          durationSeconds: 30,
          cue: 'Ride... don\'t fight.',
        ),
        GuideStep(
          instruction: 'Feel the wave beginning to crest. You don\'t have to '
              'act. The wave does not have to break on shore. Just watch it.',
          durationSeconds: 25,
          cue: 'Watch it peak...',
        ),
        GuideStep(
          instruction: 'The wave is passing. Notice the urge is slightly '
              'less intense than it was 2 minutes ago. This always happens.',
          durationSeconds: 20,
          cue: 'It\'s passing...',
        ),
        GuideStep(
          instruction: 'Urges always peak and pass — typically in 15–20 minutes. '
              'You have just proven you can ride it. This gets easier each time.',
          durationSeconds: 20,
          cue: 'You did it.',
        ),
      ],
    ),

    ResourceItem(
      id: 'audio_self_compassion',
      title: 'Self-Compassion Meditation',
      description: 'Release guilt and embrace your recovery journey.',
      emoji: '🤍',
      type: 'audio',
      categories: ['addiction', 'trauma', 'breakup'],
      isPremium: true,
      duration: '20 min',
      steps: [
        GuideStep(
          instruction: 'Find a comfortable position. Place one hand on your heart. '
              'Feel your own warmth.',
          durationSeconds: 20,
          cue: 'Hand on heart.',
        ),
        GuideStep(
          instruction: 'Think of a friend going through exactly what you\'re '
              'going through. How would you speak to them? With that same voice, '
              'speak to yourself now.',
          durationSeconds: 30,
          cue: 'Speak kindly to yourself.',
        ),
        GuideStep(
          instruction: 'Say silently: "This is a moment of suffering."',
          durationSeconds: 10,
          cue: 'This is hard.',
        ),
        GuideStep(
          instruction: 'Say silently: "Suffering is part of being human. I am not alone."',
          durationSeconds: 10,
          cue: 'I am not alone.',
        ),
        GuideStep(
          instruction: 'Say silently: "May I be kind to myself in this moment."',
          durationSeconds: 10,
          cue: 'May I be kind.',
        ),
        GuideStep(
          instruction: 'Think of one thing you\'ve done well this week — however '
              'small. Let yourself feel genuinely proud of it.',
          durationSeconds: 30,
          cue: 'I am proud of...',
        ),
        GuideStep(
          instruction: 'Now think of a mistake or setback you\'ve been carrying. '
              'Place it in your hands like an object. Look at it with gentle eyes.',
          durationSeconds: 25,
          cue: 'Hold it gently.',
        ),
        GuideStep(
          instruction: 'You are human. Humans struggle, stumble, and keep going. '
              'That\'s not weakness — it\'s the definition of being alive.',
          durationSeconds: 20,
          cue: 'You are human.',
        ),
        GuideStep(
          instruction: 'Breathe in compassion. Breathe out self-judgment. '
              'Repeat five times.',
          durationSeconds: 40,
          cue: 'In compassion. Out judgment.',
        ),
        GuideStep(
          instruction: 'Before you go, say one last thing to yourself — something '
              'you needed to hear. Something true.',
          durationSeconds: 20,
          cue: 'Say it to yourself.',
        ),
        GuideStep(
          instruction: 'Gently bring your awareness back. Open your eyes when '
              'you\'re ready. You are enough.',
          durationSeconds: 15,
          cue: 'Complete.',
        ),
      ],
    ),

    // ──────────────────────── WORKSHEETS ─────────────────────────────────

    ResourceItem(
      id: 'ws_trigger_map',
      title: 'My Trigger Map',
      description: 'Identify and map your personal triggers and patterns.',
      emoji: '🗺️',
      type: 'worksheet',
      categories: ['addiction', 'stress', 'trauma'],
      isPremium: false,
      duration: 'Interactive',
      fields: [
        WorksheetField(
          id: 'situation',
          label: 'What was happening when the urge hit?',
          hint: 'Where were you? What were you doing?',
          multiline: true,
        ),
        WorksheetField(
          id: 'people',
          label: 'Who was around, or were you alone?',
          hint: 'Name or describe the people (or lack of people)',
        ),
        WorksheetField(
          id: 'emotion_before',
          label: 'What were you feeling just before the urge?',
          hint: 'e.g. anxious, bored, angry, lonely, excited',
          multiline: true,
        ),
        WorksheetField(
          id: 'body_sensation',
          label: 'Where did you feel it in your body?',
          hint: 'e.g. tight chest, restless hands, racing heart',
        ),
        WorksheetField(
          id: 'urge_intensity',
          label: 'How strong was the urge? (1 = mild, 10 = overwhelming)',
          hint: 'Rate it honestly: 1–10',
        ),
        WorksheetField(
          id: 'what_i_did',
          label: 'What did you actually do?',
          hint: 'No judgment — just honest.',
          multiline: true,
        ),
        WorksheetField(
          id: 'alternative',
          label: 'What could you do differently next time this trigger appears?',
          hint: 'One specific action or coping tool',
          multiline: true,
        ),
      ],
    ),

    ResourceItem(
      id: 'ws_gratitude',
      title: 'Gratitude Journal Template',
      description: '30-day gratitude practice with daily prompts.',
      emoji: '🙏',
      type: 'worksheet',
      categories: ['stress', 'breakup', 'addiction'],
      isPremium: false,
      duration: 'Daily Practice',
      fields: [
        WorksheetField(
          id: 'grateful_1',
          label: 'I\'m grateful for (1)',
          hint: 'Something specific — big or small',
        ),
        WorksheetField(
          id: 'grateful_2',
          label: 'I\'m grateful for (2)',
          hint: 'Something you might normally take for granted',
        ),
        WorksheetField(
          id: 'grateful_3',
          label: 'I\'m grateful for (3)',
          hint: 'Something about yourself',
        ),
        WorksheetField(
          id: 'who_helped',
          label: 'Someone who helped or supported me today',
          hint: 'Even in a small way',
        ),
        WorksheetField(
          id: 'small_win',
          label: 'One small win today',
          hint: 'Anything you did well or managed to do',
        ),
        WorksheetField(
          id: 'kind_thought',
          label: 'A kind thought for myself',
          hint: 'Something you\'d say to a dear friend',
          multiline: true,
        ),
      ],
    ),

    ResourceItem(
      id: 'ws_urge_log',
      title: 'Urge Surfing Log',
      description: 'Track urges, triggers, and outcomes to find your patterns.',
      emoji: '📋',
      type: 'worksheet',
      categories: ['addiction'],
      isPremium: false,
      duration: 'As Needed',
      fields: [
        WorksheetField(
          id: 'urge_trigger',
          label: 'What triggered this urge?',
          hint: 'Situation, feeling, or thought',
          multiline: true,
        ),
        WorksheetField(
          id: 'urge_intensity_start',
          label: 'Intensity at start (1–10)',
          hint: 'How strong was it when you first noticed?',
        ),
        WorksheetField(
          id: 'body_feelings',
          label: 'What did you notice in your body?',
          hint: 'Physical sensations during the urge',
          multiline: true,
        ),
        WorksheetField(
          id: 'coping_tool',
          label: 'What coping tool did you use?',
          hint: 'Breathing, grounding, calling someone, distraction...',
        ),
        WorksheetField(
          id: 'urge_intensity_end',
          label: 'Intensity after coping (1–10)',
          hint: 'How strong was it once you used your tool?',
        ),
        WorksheetField(
          id: 'outcome',
          label: 'What happened? Did you ride it out?',
          hint: 'Honest reflection — no judgment',
          multiline: true,
        ),
        WorksheetField(
          id: 'learning',
          label: 'What did you learn from this urge?',
          hint: 'Even one insight counts',
          multiline: true,
        ),
      ],
    ),

    ResourceItem(
      id: 'ws_values',
      title: 'Values Clarification Worksheet',
      description: 'Reconnect with your core values and goals.',
      emoji: '⭐',
      type: 'worksheet',
      categories: ['addiction', 'breakup', 'trauma', 'stress'],
      isPremium: true,
      duration: '30 min',
      fields: [
        WorksheetField(
          id: 'top_values',
          label: 'My top 5 personal values',
          hint: 'e.g. honesty, family, freedom, health, creativity',
          multiline: true,
        ),
        WorksheetField(
          id: 'values_before',
          label: 'Which values were I honouring before my struggle?',
          hint: 'Think back to a time you felt like yourself',
          multiline: true,
        ),
        WorksheetField(
          id: 'values_violated',
          label: 'Which values has my struggle most violated?',
          hint: 'Be honest — this isn\'t about shame, it\'s about clarity',
          multiline: true,
        ),
        WorksheetField(
          id: 'smallest_step',
          label: 'What is the smallest step I can take this week to honour one value?',
          hint: 'One specific action, one day this week',
          multiline: true,
        ),
        WorksheetField(
          id: 'life_vision',
          label: 'If I were fully living my values, what would my life look like in 1 year?',
          hint: 'Write freely — be specific',
          multiline: true,
        ),
      ],
    ),

    ResourceItem(
      id: 'ws_relapse_prevention',
      title: 'Relapse Prevention Plan',
      description: 'Build your personalised relapse prevention strategy.',
      emoji: '🛡️',
      type: 'worksheet',
      categories: ['addiction'],
      isPremium: true,
      duration: '45 min',
      fields: [
        WorksheetField(
          id: 'warning_signs',
          label: 'My early warning signs (thoughts, feelings, behaviours)',
          hint: 'What happens just before things get hard? Be specific.',
          multiline: true,
        ),
        WorksheetField(
          id: 'high_risk_situations',
          label: 'My top 3 high-risk situations',
          hint: 'When, where, or with whom am I most vulnerable?',
          multiline: true,
        ),
        WorksheetField(
          id: 'coping_strategies',
          label: 'My coping strategies for each situation',
          hint: 'What will I do instead? Be specific for each situation.',
          multiline: true,
        ),
        WorksheetField(
          id: 'support_people',
          label: 'People I will call before I act on an urge',
          hint: 'Names and phone numbers — fill these in now',
          multiline: true,
        ),
        WorksheetField(
          id: 'if_i_slip',
          label: 'If I slip, my plan is...',
          hint: 'Who do I call? What do I do first? How do I get back on track?',
          multiline: true,
        ),
        WorksheetField(
          id: 'my_reasons',
          label: 'My reasons for recovery (read this when it gets hard)',
          hint: 'Write from the heart — who are you doing this for? Why?',
          multiline: true,
        ),
      ],
    ),

    // ──────────────────────── VIDEOS ─────────────────────────────────────

    ResourceItem(
      id: 'video_recovery_stories',
      title: 'Recovery Stories: Real People, Real Journeys',
      description: 'Inspiring first-person accounts of recovery from addiction and trauma.',
      emoji: '🎬',
      type: 'video',
      categories: ['addiction', 'trauma', 'breakup'],
      videoTopic: 'stories',
      isPremium: false,
      duration: '18 min',
      videoUrl: 'https://www.youtube.com/results?search_query=addiction+recovery+stories+TED',
      videoDescription:
        'Recovery looks different for everyone. These stories remind us that '
        'healing is possible — even when it feels impossible. Hear from real '
        'people who have navigated addiction, loss, and trauma, and found their '
        'way through.\n\n'
        'What to expect:\n'
        '• Personal accounts of the moment things began to change\n'
        '• Honest discussion of setbacks and how they were navigated\n'
        '• Practical insights from people who have been exactly where you are\n\n'
        'Recommended search: "addiction recovery real stories" on YouTube for '
        'TEDx talks and documentary content.',
    ),

    ResourceItem(
      id: 'video_grief_stages',
      title: 'Understanding Grief & Loss',
      description: 'A compassionate guide through loss and heartbreak.',
      emoji: '💔',
      type: 'video',
      categories: ['breakup', 'trauma'],
      videoTopic: 'therapy',
      isPremium: false,
      duration: '14 min',
      videoUrl: 'https://www.youtube.com/results?search_query=David+Kessler+grief+explained',
      videoDescription:
        'Grief is not a linear process, and it\'s not just about death. '
        'Breakups, loss of identity, loss of a relationship with substances, '
        'loss of health — all of these involve real grief.\n\n'
        'Topics covered:\n'
        '• Why the "5 stages of grief" is a starting point, not a roadmap\n'
        '• The difference between grief and depression\n'
        '• How grief changes over time — and how to support the process\n'
        '• When to seek professional support\n\n'
        'Recommended: Search "David Kessler grief" or "complicated grief psychology" '
        'on YouTube.',
    ),

    ResourceItem(
      id: 'video_cbt_addiction',
      title: 'CBT for Addiction',
      description: 'How Cognitive Behavioural Therapy supports recovery.',
      emoji: '🧩',
      type: 'video',
      categories: ['addiction', 'stress'],
      videoTopic: 'therapy',
      isPremium: true,
      duration: '25 min',
      videoUrl: 'https://www.youtube.com/results?search_query=CBT+relapse+prevention+addiction+Judith+Beck',
      videoDescription:
        'Cognitive Behavioural Therapy (CBT) is one of the most evidence-based '
        'treatments for addiction and relapse prevention. This video explains '
        'the core concepts and how to apply them yourself.\n\n'
        'What you\'ll learn:\n'
        '• The CBT model — how thoughts drive feelings and behaviours\n'
        '• Identifying cognitive distortions (all-or-nothing thinking, catastrophising)\n'
        '• Challenging automatic negative thoughts\n'
        '• Behavioural experiments you can run yourself\n'
        '• The ABC model for analysing high-risk situations\n\n'
        'Recommended: Search "CBT for addiction explained" or "Aaron Beck CBT" '
        'on YouTube.',
    ),

    ResourceItem(
      id: 'video_yoga_healing',
      title: 'Yoga for Emotional Healing',
      description: 'Gentle movement practices to release stored trauma.',
      emoji: '🧘',
      type: 'video',
      categories: ['trauma', 'stress'],
      videoTopic: 'body',
      isPremium: true,
      duration: '30 min',
      videoUrl: 'https://www.youtube.com/results?search_query=trauma+center+trauma+sensitive+yoga+10+minutes',
      videoDescription:
        'Trauma is stored in the body, not just the mind. Trauma-sensitive yoga '
        'uses gentle movement and breath to help the nervous system discharge '
        'stored stress and return to a state of safety.\n\n'
        'This practice is:\n'
        '• Beginner-friendly — no experience needed\n'
        '• Trauma-informed — you are always in control of your body\n'
        '• Focused on breathwork and gentle movement, not performance\n'
        '• Suitable for people with physical limitations\n\n'
        'Recommended: Search "trauma sensitive yoga" or "Bessel van der Kolk yoga '
        'trauma" on YouTube. The Trauma Center in Boston has excellent free content.',
    ),

    ResourceItem(
      id: 'video_mindfulness_intro',
      title: 'Mindfulness for Urges (10‑Minute Primer)',
      description: 'Observe thoughts and cravings without acting — skills you can reuse daily.',
      emoji: '🌿',
      type: 'video',
      categories: ['addiction', 'stress', 'habits'],
      videoTopic: 'therapy',
      isPremium: false,
      duration: '10 min',
      videoUrl: 'https://www.youtube.com/results?search_query=urge+surfing+mindfulness+addiction+10+minutes',
      videoDescription:
        'Urge surfing and “name it to tame it” are staples of relapse prevention. '
        'This style of practice helps you stay with discomfort until it crests and falls.\n\n'
        'Try searches: “urge surfing mindfulness”, “SOBER breathing exercise”, or '
        '“cravings mindfulness UCLA MARC”.',
    ),

    ResourceItem(
      id: 'video_sleep_recovery',
      title: 'Sleep, Cravings & Recovery',
      description: 'Why sleep debt spikes impulsivity — and how to protect a wind‑down window.',
      emoji: '🌙',
      type: 'video',
      categories: ['addiction', 'stress', 'habits'],
      videoTopic: 'science',
      isPremium: false,
      duration: '12 min',
      videoUrl: 'https://www.youtube.com/results?search_query=sleep+deprivation+impulsivity+addiction+recovery+Matthew+Walker',
      videoDescription:
        'Sleep is not “soft” self‑care — it is frontal‑lobe fuel. Short nights nudge the same '
        'brain circuits that make urges louder.\n\n'
        'Look for: Matthew Walker sleep impulsivity, Huberman sleep toolkit, or '
        '“sleep hygiene CBTI” for structured wind‑down routines.',
    ),

    ResourceItem(
      id: 'video_dopamine_reset',
      title: 'Dopamine & Reward: Motivation After Quitting',
      description: 'Understand flat periods after you stop — and how healthy rewards help.',
      emoji: '⚡',
      type: 'video',
      categories: ['addiction', 'habits', 'discipline'],
      videoTopic: 'motivation',
      isPremium: true,
      duration: '16 min',
      videoUrl: 'https://www.youtube.com/results?search_query=Anna+Lembke+dopamine+detox+reward+system+explained',
      videoDescription:
        'Many people hit anhedonia (“nothing feels good”) early in abstinence. '
        'That is often a healing brain recalibrating reward thresholds — not proof recovery failed.\n\n'
        'Search: “Anna Lembke dopamine”, “reward deficiency addiction”, or '
        '“behavioral activation depression motivation”.',
    ),

    ResourceItem(
      id: 'video_neuroscience_addiction',
      title: 'Addiction as a Brain Disease (Explainer)',
      description: 'Clear, non‑judgemental science on circuits, tolerance, and healing time.',
      emoji: '🧠',
      type: 'video',
      categories: ['addiction', 'trauma'],
      videoTopic: 'science',
      isPremium: false,
      duration: '15 min',
      videoUrl: 'https://www.youtube.com/results?search_query=Nora+Volkow+addiction+brain+disease+explained',
      videoDescription:
        'NIDA‑aligned framing: addiction involves learning, stress systems, and executive control — '
        'not a moral failing.\n\n'
        'Try: “Nora Volkow addiction brain”, “ASAM definition addiction”, or '
        '“Huberman alcohol neuroscience” for deeper dives.',
    ),

    ResourceItem(
      id: 'video_peer_support',
      title: 'Peer Support & SMART / 12‑Step (Orientation)',
      description: 'What happens in groups — and how to pick a format that fits you.',
      emoji: '🤝',
      type: 'video',
      categories: ['addiction', 'breakup'],
      videoTopic: 'motivation',
      isPremium: false,
      duration: '11 min',
      videoUrl: 'https://www.youtube.com/results?search_query=SMART+Recovery+meeting+what+to+expect+orientation',
      videoDescription:
        'Community is a protective factor. This entry points you to respectful, evidence‑friendly '
        'overviews before you walk into a room (virtual or in‑person).\n\n'
        'Search: “SMART Recovery tools”, “AA newcomer expectations”, or “recovery capital peer support”.',
    ),

    // ── Gym · Habits · Discipline (life training) ─────────────────────────

    ResourceItem(
      id: 'article_gym_basics',
      title: 'Training Basics That Stick',
      description: 'Progressive overload, rest, and logging — without burning out.',
      emoji: '🏋️',
      type: 'article',
      categories: ['gym', 'habits', 'discipline'],
      isPremium: false,
      duration: '6 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'You do not need a perfect program on day one. You need a simple loop: '
          'show up, log what you did, sleep, repeat. Recovery and fitness both reward '
          'consistency more than intensity spikes.'),
        ContentSection(type: 'heading', content: 'Log every session'),
        ContentSection(type: 'paragraph', content:
          'Write sets, reps, and weight (or time for cardio). The log is proof you '
          'are moving forward — and it tells you when to add a little load or one more rep.'),
        ContentSection(type: 'heading', content: 'Progressive overload'),
        ContentSection(type: 'paragraph', content:
          'Each week, aim for one small improvement: one more rep, slightly more weight, '
          'or better form on the same load. Tiny steps compound.'),
        ContentSection(type: 'tip', content:
          'Use Reclaim’s Gym log on Home to track exercises like a simple workout journal.'),
      ],
    ),

    ResourceItem(
      id: 'article_habit_stack',
      title: 'Habit Stacking for Recovery',
      description: 'Attach new habits to anchors you already do every day.',
      emoji: '🔗',
      type: 'article',
      categories: ['habits', 'discipline', 'addiction'],
      isPremium: false,
      duration: '5 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'After I [current habit], I will [new habit]. Examples: after I brush my teeth, '
          'I will take three deep breaths. After I pour morning coffee, I will write one line in my journal.'),
        ContentSection(type: 'heading', content: 'Keep the new habit tiny'),
        ContentSection(type: 'paragraph', content:
          'If it takes less than two minutes, you are far more likely to keep it. '
          'You can always scale up once the chain is unbroken.'),
        ContentSection(type: 'quote', content:
          '"You do not rise to the level of your goals. You fall to the level of your systems." — James Clear'),
      ],
    ),

    ResourceItem(
      id: 'article_discipline_nonnegotiables',
      title: 'Non‑Negotiables & Deep Work',
      description: 'Protect focus blocks the same way you protect meetings.',
      emoji: '🎯',
      type: 'article',
      categories: ['discipline', 'habits', 'stress'],
      isPremium: false,
      duration: '6 min read',
      sections: [
        ContentSection(type: 'paragraph', content:
          'Pick one to three non‑negotiables per day: movement, sleep window, or a '
          'focus block without your phone. Treat them like appointments you cannot cancel.'),
        ContentSection(type: 'heading', content: 'Deep work blocks'),
        ContentSection(type: 'bullet', content: 'Same time each day when possible — your brain loves rhythm.'),
        ContentSection(type: 'bullet', content: 'Phone in another room or airplane mode.'),
        ContentSection(type: 'bullet', content: 'End with a 60‑second review: what moved forward?'),
        ContentSection(type: 'tip', content:
          'Pair with Reclaim’s Pomodoro on the Focus tab for timed work/rest cycles.'),
      ],
    ),

    ResourceItem(
      id: 'audio_walk_reset',
      title: '10‑Minute Walk Reset',
      description: 'Light movement between desk blocks — good for body and cravings.',
      emoji: '🚶',
      type: 'audio',
      categories: ['gym', 'habits', 'stress'],
      isPremium: false,
      duration: '10 min',
      steps: [
        GuideStep(
          instruction: 'Stand up. Roll your shoulders back three times.',
          durationSeconds: 15,
          cue: 'Wake the body…',
        ),
        GuideStep(
          instruction: 'Walk slowly for two minutes. Notice heel, arch, toe on each step.',
          durationSeconds: 120,
          cue: 'Mindful steps…',
        ),
        GuideStep(
          instruction: 'Pick up pace slightly. Breathe in for three steps, out for three.',
          durationSeconds: 180,
          cue: 'Steady rhythm…',
        ),
        GuideStep(
          instruction: 'Slow down. Name one thing you will do next with full attention.',
          durationSeconds: 60,
          cue: 'Set intention…',
        ),
        GuideStep(
          instruction: 'You are done. Sip water and return refreshed.',
          durationSeconds: 10,
          cue: 'Complete.',
        ),
      ],
    ),

    ResourceItem(
      id: 'ws_gym_session',
      title: 'Session Plan (Push / Pull / Legs)',
      description: 'Sketch today’s lifts before you hit the floor.',
      emoji: '📋',
      type: 'worksheet',
      categories: ['gym', 'discipline'],
      isPremium: false,
      duration: '10 min',
      fields: [
        WorksheetField(
          id: 'day_type',
          label: 'Today is (push / pull / legs / other)',
          hint: 'e.g. Push — chest, shoulders, triceps',
        ),
        WorksheetField(
          id: 'warmup',
          label: 'Warm‑up (5–10 min)',
          hint: 'Bike, row, dynamic stretches…',
          multiline: true,
        ),
        WorksheetField(
          id: 'main_lifts',
          label: 'Main lifts (exercise · target sets × reps)',
          hint: 'Bench 4×6, OHP 3×8…',
          multiline: true,
        ),
        WorksheetField(
          id: 'accessory',
          label: 'Accessory / finisher',
          hint: 'Optional — curls, core, carries…',
          multiline: true,
        ),
        WorksheetField(
          id: 'exit_note',
          label: 'One line after the session',
          hint: 'Energy 1–10, what to adjust next time',
          multiline: true,
        ),
      ],
    ),
  ];

  /// Filter resources by type and optionally by category.
  /// For `type == video`, [videoTopic] and [videoSearch] narrow the list further.
  static List<ResourceItem> byType(
    String type, {
    String category = 'all',
    String videoTopic = 'all',
    String videoSearch = '',
  }) {
    final q = videoSearch.trim().toLowerCase();
    return all.where((r) {
      final typeMatch = r.type == type;
      final catMatch = category == 'all' || r.categories.contains(category);
      if (!typeMatch || !catMatch) return false;
      if (type != 'video') return true;
      final topic = r.videoTopic ?? 'general';
      final topicMatch = videoTopic == 'all' || topic == videoTopic;
      if (!topicMatch) return false;
      if (q.isEmpty) return true;
      final blob =
          '${r.title} ${r.description} ${r.videoDescription ?? ''}'.toLowerCase();
      return blob.contains(q);
    }).toList();
  }
}
