// Curated content shown in the Craving Shield screen per addiction type.
// Videos open as YouTube searches (always fresh content).
// Stories are factual, evidence-based consequence narratives.
// Sounds use the existing ambient audio URLs.

class CravingVideo {
  const CravingVideo({
    required this.title,
    required this.description,
    required this.searchQuery,
  });
  final String title, description, searchQuery;

  String get youtubeSearchUrl =>
      'https://m.youtube.com/results?search_query=${Uri.encodeQueryComponent(searchQuery)}';
}

class CravingStory {
  const CravingStory({
    required this.emoji,
    required this.color,
    required this.headline,
    required this.body,
    required this.source,
  });
  final String emoji;
  final int color; // ARGB
  final String headline, body, source;
}

class CravingSound {
  const CravingSound({
    required this.emoji,
    required this.name,
    required this.why,
    required this.audioUrl,
  });
  final String emoji, name, why, audioUrl;
}

class AddictionContent {
  const AddictionContent({
    required this.key,
    required this.label,
    required this.emoji,
    required this.videos,
    required this.stories,
    required this.sounds,
  });
  final String key, label, emoji;
  final List<CravingVideo> videos;
  final List<CravingStory> stories;
  final List<CravingSound> sounds;
}

// ── Audio URLs (from ambient catalog) ─────────────────────────────────────────

const _ocean   = 'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/1f/Waves.ogg/Waves.ogg.mp3';
const _forest  = 'https://upload.wikimedia.org/wikipedia/commons/transcoded/4/42/Bird_singing.ogg/Bird_singing.ogg.mp3';
const _bowl    = 'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/17/Small_tibetan_singing_bowl.ogg/Small_tibetan_singing_bowl.ogg.mp3';
const _rain    = 'https://archive.org/download/naturesounds-soundtheraphy/Light%20Gentle%20Rain.mp3';
const _campfire= 'https://upload.wikimedia.org/wikipedia/commons/transcoded/b/b1/Campfire_sound_ambience.ogg/Campfire_sound_ambience.ogg.mp3';

// ── Content map ───────────────────────────────────────────────────────────────

const Map<String, AddictionContent> cravingContent = {

  // ── Alcohol ──────────────────────────────────────────────────────────────
  'alcohol': AddictionContent(
    key: 'alcohol', label: 'Alcohol', emoji: '🍺',
    videos: [
      CravingVideo(
        title: 'Real Stories: The Cost of Alcohol',
        description: 'Personal accounts of how alcohol dependency changed lives, health, and families.',
        searchQuery: 'alcohol addiction real stories documentary consequences',
      ),
      CravingVideo(
        title: 'What Alcohol Does to Your Brain',
        description: 'The neuroscience of how alcohol physically rewires your brain over time.',
        searchQuery: 'alcohol addiction brain science what it does inside',
      ),
      CravingVideo(
        title: 'Recovering: Life After Alcohol',
        description: 'Inspiring real accounts of people who got sober and rebuilt their lives.',
        searchQuery: 'alcohol addiction recovery sober real story motivation',
      ),
    ],
    stories: [
      CravingStory(
        emoji: '⚠️', color: 0xFFFF6B35,
        headline: 'Your liver starts failing silently',
        body: 'Heavy drinking for 10+ years causes fatty liver in 90% of people. Of those, 1 in 5 develop cirrhosis — permanent, irreversible scarring. The liver can\'t signal pain until it\'s too late. Most people find out at stage 3 or 4, when options are almost gone.\n\nThe good news: stop today, and your liver begins healing within 4–8 weeks. The window is open right now.',
        source: 'Source: National Institute on Alcohol Abuse and Alcoholism',
      ),
      CravingStory(
        emoji: '🚗', color: 0xFFE63946,
        headline: 'You feel fine. You are not.',
        body: 'At the legal limit of 0.08% BAC, your braking time slows by 30% and peripheral vision drops by 32%. You cannot feel either of these changes happening — that\'s what makes them deadly.\n\nIn 2022, over 13,500 people were killed in alcohol-impaired crashes in the US alone. Every single driver thought they were fine.',
        source: 'Source: NHTSA Traffic Safety Facts 2022',
      ),
      CravingStory(
        emoji: '👨‍👧', color: 0xFF6A4C93,
        headline: 'Children of alcoholics are 4× more likely to develop alcoholism',
        body: 'Every drink you take in front of a child writes their future. The pattern is passed forward — not through choice, but through the brain\'s learned stress response.\n\nEvery sober day you choose breaks that chain. You\'re not just saving yourself. You\'re rewriting what comes next.',
        source: 'Source: American Academy of Child & Adolescent Psychiatry',
      ),
    ],
    sounds: [
      CravingSound(emoji: '🌊', name: 'Ocean Waves', why: 'Slows heart rate and quiets the craving reflex.', audioUrl: _ocean),
      CravingSound(emoji: '🔔', name: 'Singing Bowl', why: 'The single tone draws focus away from the urge.', audioUrl: _bowl),
      CravingSound(emoji: '🌧️', name: 'Gentle Rain', why: 'Rain sounds activate the parasympathetic nervous system.', audioUrl: _rain),
    ],
  ),

  // ── Drugs ─────────────────────────────────────────────────────────────────
  'drugs': AddictionContent(
    key: 'drugs', label: 'Drugs', emoji: '💊',
    videos: [
      CravingVideo(
        title: 'Inside the Brain on Drugs',
        description: 'How substances permanently alter dopamine pathways and motivation systems.',
        searchQuery: 'drug addiction brain dopamine documentary what happens',
      ),
      CravingVideo(
        title: 'The Overdose Crisis: Real Stories',
        description: 'Families and survivors speak about the reality of addiction and overdose.',
        searchQuery: 'drug overdose crisis real family stories documentary',
      ),
      CravingVideo(
        title: 'Recovery Is Possible',
        description: 'Stories of people who hit rock bottom and built remarkable lives in recovery.',
        searchQuery: 'drug addiction recovery real story sober motivation',
      ),
    ],
    stories: [
      CravingStory(
        emoji: '🧠', color: 0xFF4361EE,
        headline: 'One use can rewire your reward system permanently',
        body: 'A single dose of methamphetamine can reduce dopamine receptors by 20–30%. Your brain\'s ability to feel natural pleasure — from food, connection, achievement — is diminished. It can take 12–18 months of sobriety to begin recovery of these pathways.\n\nYou are not weak. Your brain was hijacked. And brains can heal — but only with time sober.',
        source: 'Source: National Institute on Drug Abuse (NIDA)',
      ),
      CravingStory(
        emoji: '📉', color: 0xFFE63946,
        headline: 'Drug overdose is now the #1 cause of accidental death in the US',
        body: 'In 2022, over 107,000 Americans died from drug overdoses — more than car accidents and gun violence combined. Most had used many times before without dying. Most had people who loved them.\n\nFentanyl has made every use a gamble with unknown stakes. There is no "safe" tolerance.',
        source: 'Source: CDC National Center for Health Statistics 2022',
      ),
      CravingStory(
        emoji: '🌱', color: 0xFF2A9D8F,
        headline: 'Your brain\'s neuroplasticity is a superpower in recovery',
        body: 'The same plasticity that made you dependent can rebuild you. Studies show that after 1 year of sobriety, grey matter volume increases, memory improves, and emotional regulation strengthens significantly.\n\nEvery day without use is a day your brain is physically rebuilding itself. The work is invisible — but it\'s happening.',
        source: 'Source: Journal of Neuroscience, Recovery & Neuroplasticity Review',
      ),
    ],
    sounds: [
      CravingSound(emoji: '🌲', name: 'Forest Birds', why: 'Nature sounds interrupt the craving thought loop.', audioUrl: _forest),
      CravingSound(emoji: '🔔', name: 'Singing Bowl', why: 'Grounds awareness in the present, not the craving.', audioUrl: _bowl),
      CravingSound(emoji: '🌊', name: 'Ocean Waves', why: 'Steady rhythm resets the nervous system.', audioUrl: _ocean),
    ],
  ),

  // ── Gambling ──────────────────────────────────────────────────────────────
  'gambling': AddictionContent(
    key: 'gambling', label: 'Gambling', emoji: '🎰',
    videos: [
      CravingVideo(
        title: 'The Psychology of Gambling Addiction',
        description: 'How casinos and apps are engineered to exploit the brain\'s reward system.',
        searchQuery: 'gambling addiction psychology documentary how it works brain',
      ),
      CravingVideo(
        title: 'Real Stories: When Gambling Took Everything',
        description: 'Personal accounts of financial ruin, family loss, and the road back.',
        searchQuery: 'gambling addiction real story lost everything documentary',
      ),
      CravingVideo(
        title: 'Breaking Free: Gambling Recovery',
        description: 'How people rebuild their finances and relationships after gambling addiction.',
        searchQuery: 'gambling addiction recovery financial rebuild story',
      ),
    ],
    stories: [
      CravingStory(
        emoji: '📊', color: 0xFFE63946,
        headline: 'The house always wins. That\'s not a cliché — it\'s mathematics.',
        body: 'Every casino game is engineered to return less than you put in over time. Slot machines return 85–97 cents per dollar. Roulette\'s house edge is 5.26%. Sports betting apps take 4–10% on every bet.\n\nThe feeling that "this time is different" is the addiction talking. The odds are fixed. They never change.',
        source: 'Source: National Council on Problem Gambling',
      ),
      CravingStory(
        emoji: '💔', color: 0xFF9C27B0,
        headline: 'Problem gamblers have the highest suicide rate of any addiction',
        body: 'Studies show that 20% of pathological gamblers have attempted suicide — higher than alcohol, drugs, or any other behavioral addiction. Financial shame, secrecy, and the sense of no way out drive this pattern.\n\nThere is always a way out. Debt can be restructured. Relationships can be rebuilt. But only if you\'re alive to do it.',
        source: 'Source: Journal of Gambling Studies, Suicide Risk Review',
      ),
      CravingStory(
        emoji: '🏠', color: 0xFF4361EE,
        headline: r'The average problem gambler loses $55,000 before seeking help',
        body: 'By the time most gamblers recognise they have a problem, the average debt is \$55,000. That\'s a down payment on a home. A child\'s university education. A decade of family holidays.\n\nThe next bet won\'t win it back. It never does. But every hour you don\'t gamble is money still in your pocket.',
        source: 'Source: National Council on Problem Gambling, Financial Impact Study',
      ),
    ],
    sounds: [
      CravingSound(emoji: '🌊', name: 'Ocean Waves', why: 'Calm the racing mind that drives impulsive bets.', audioUrl: _ocean),
      CravingSound(emoji: '🌧️', name: 'Gentle Rain', why: 'Steady rain resets the high-arousal gambling state.', audioUrl: _rain),
      CravingSound(emoji: '🔔', name: 'Singing Bowl', why: 'Brings focus back to the present moment, not the next bet.', audioUrl: _bowl),
    ],
  ),

  // ── Smoking ───────────────────────────────────────────────────────────────
  'smoking': AddictionContent(
    key: 'smoking', label: 'Smoking', emoji: '🚬',
    videos: [
      CravingVideo(
        title: 'What Smoking Does to Your Body',
        description: 'A clear visual breakdown of how every cigarette affects your lungs, heart, and arteries.',
        searchQuery: 'smoking what it does to your body documentary health effects',
      ),
      CravingVideo(
        title: 'Real Stories: Quitting Smoking',
        description: 'People who quit after 10, 20, 30 years — and what changed.',
        searchQuery: 'quitting smoking real success stories 20 years health recovery',
      ),
      CravingVideo(
        title: 'The Nicotine Trap: How It Hooks You',
        description: 'The science of nicotine addiction — why every craving only lasts 3 minutes.',
        searchQuery: 'nicotine addiction science 3 minute craving how brain hooked',
      ),
    ],
    stories: [
      CravingStory(
        emoji: '⏱️', color: 0xFF2A9D8F,
        headline: 'This craving will peak and pass in 3–5 minutes',
        body: 'Nicotine cravings are intensely uncomfortable but physically brief. Peak intensity lasts 3–5 minutes, then the craving fades — whether or not you smoke.\n\nYou don\'t need to fight it forever. You just need to outlast 5 minutes. Right now, you\'re already part of the way through.',
        source: 'Source: American Cancer Society, Craving Science',
      ),
      CravingStory(
        emoji: '❤️', color: 0xFFE63946,
        headline: 'Your heart heals faster than you think',
        body: '20 minutes after your last cigarette: blood pressure drops. 12 hours: carbon monoxide levels normalise. 1 year sober: your heart attack risk is already half that of a smoker.\n\nYour body is not waiting for permission to heal. It starts the moment you stop.',
        source: 'Source: NHS, Benefits of Quitting Smoking Timeline',
      ),
      CravingStory(
        emoji: '💶', color: 0xFF4361EE,
        headline: 'One pack a day = ₹1,64,250 per year',
        body: 'At ₹450 per pack, a pack-a-day smoker spends over ₹1.6 lakh every year on cigarettes. Over 10 years, that\'s ₹16 lakh — enough for a car, a renovation, or years of family memories.\n\nYou\'re paying for something that\'s damaging your health, shortening your life, and taking your money. The deal is completely one-sided.',
        source: 'Source: Average Indian cigarette costs, financial projection',
      ),
    ],
    sounds: [
      CravingSound(emoji: '🌲', name: 'Forest Birds', why: 'Fresh air sounds reinforce why clean lungs matter.', audioUrl: _forest),
      CravingSound(emoji: '🔥', name: 'Campfire', why: 'Warmth without smoke — a safe sensory replacement.', audioUrl: _campfire),
      CravingSound(emoji: '🌊', name: 'Ocean Waves', why: 'Steady breathing rhythm to ride out the 5-minute craving.', audioUrl: _ocean),
    ],
  ),

  // ── Social Media ──────────────────────────────────────────────────────────
  'social_media': AddictionContent(
    key: 'social_media', label: 'Social Media', emoji: '📱',
    videos: [
      CravingVideo(
        title: 'The Social Dilemma — Documentary',
        description: 'Former tech engineers reveal how social media platforms are designed to be addictive.',
        searchQuery: 'social dilemma documentary social media addiction designed',
      ),
      CravingVideo(
        title: 'Social Media and Mental Health: The Evidence',
        description: 'What research actually shows about anxiety, depression, and screen time.',
        searchQuery: 'social media mental health depression anxiety research documentary',
      ),
      CravingVideo(
        title: 'Digital Detox: Life After Quitting',
        description: 'People who deleted social media apps and what happened to their lives.',
        searchQuery: 'quit social media digital detox real story changed life',
      ),
    ],
    stories: [
      CravingStory(
        emoji: '⏰', color: 0xFF9C27B0,
        headline: 'You\'re spending 6 years on social media in your lifetime',
        body: 'The average person spends 2 hours 27 minutes per day on social media. Over a lifetime, that\'s 6 years and 8 months — staring at a screen designed to keep you there.\n\nIn that time, you could learn a new language, write a book, build a business, or simply be present with the people who love you.',
        source: 'Source: DataReportal Global Digital Overview 2024',
      ),
      CravingStory(
        emoji: '😟', color: 0xFFE63946,
        headline: 'Heavy social media use increases depression risk by 66%',
        body: 'A 2018 University of Pennsylvania study found that limiting social media to 30 minutes per day led to significant reductions in loneliness and depression within 3 weeks.\n\nThe platform shows you everyone\'s highlight reel. Your brain compares it to your behind-the-scenes. That comparison is making you feel worse about a life that is actually fine.',
        source: 'Source: Journal of Social and Clinical Psychology, 2018',
      ),
      CravingStory(
        emoji: '🧠', color: 0xFF4361EE,
        headline: 'Endless scrolling physically shortens your attention span',
        body: 'Studies show that frequent social media users show reduced grey matter density in areas governing impulse control and attention. The constant micro-stimulation trains your brain to reject anything that isn\'t immediately rewarding.\n\nBooks feel boring. Conversations feel slow. Deep work becomes impossible. This is not who you are — it\'s what the algorithm trained you to become.',
        source: 'Source: Frontiers in Human Neuroscience, 2022',
      ),
    ],
    sounds: [
      CravingSound(emoji: '🌿', name: 'Forest Birdsong', why: 'Real-world sounds pull attention away from the screen.', audioUrl: _forest),
      CravingSound(emoji: '🌧️', name: 'Gentle Rain', why: 'Sustained focus sound — the opposite of scroll stimulation.', audioUrl: _rain),
      CravingSound(emoji: '🔔', name: 'Singing Bowl', why: 'Single point of focus to reset the scattered attention.', audioUrl: _bowl),
    ],
  ),

  // ── Other ─────────────────────────────────────────────────────────────────
  'other': AddictionContent(
    key: 'other', label: 'Other', emoji: '🔄',
    videos: [
      CravingVideo(
        title: 'The Science of Craving',
        description: 'How cravings form in the brain and why urge surfing works.',
        searchQuery: 'craving science brain urge surfing addiction documentary',
      ),
      CravingVideo(
        title: 'Breaking the Habit Loop',
        description: 'The neuroscience of habits and how to replace destructive ones.',
        searchQuery: 'breaking addiction habit loop brain documentary science',
      ),
      CravingVideo(
        title: 'Real Recovery: Against the Odds',
        description: 'Stories of people who overcame addiction and built meaningful lives.',
        searchQuery: 'addiction recovery real story motivation against the odds sober',
      ),
    ],
    stories: [
      CravingStory(
        emoji: '🌊', color: 0xFF2A9D8F,
        headline: 'Urge surfing: the craving is a wave, not a wall',
        body: 'Every craving follows a curve — it rises, peaks, and falls. The average urge lasts 15–30 minutes at most. You do not have to "defeat" it. You only need to ride it.\n\nAcknowledge it: "I notice I\'m craving ___." Watch it. It will pass whether you act on it or not.',
        source: 'Source: Marlatt & Gordon, Relapse Prevention Theory',
      ),
      CravingStory(
        emoji: '🔁', color: 0xFF4361EE,
        headline: 'Every time you resist, you physically weaken the habit',
        body: 'Each time you experience a craving and don\'t act on it, the neural pathway that drives that habit weakens slightly. Each resistance is a small act of neurological rewiring.\n\nYou don\'t break a habit all at once. You erode it, one passed craving at a time. Tonight counts.',
        source: 'Source: Neuroscience of Habit Formation, MIT Research',
      ),
      CravingStory(
        emoji: '🤍', color: 0xFF9C27B0,
        headline: 'Relapse is part of recovery — not the end of it',
        body: 'The average person trying to break an addiction makes 8–11 attempts before achieving lasting sobriety. This is not failure — it\'s the normal process of rewiring a brain.\n\nEvery attempt teaches something. Every attempt makes the next attempt more likely to succeed. You are not behind. You are exactly where most people are.',
        source: 'Source: SAMHSA, Recovery and the Process of Change',
      ),
    ],
    sounds: [
      CravingSound(emoji: '🌊', name: 'Ocean Waves', why: 'Matches the "wave" of craving — let it rise and fall.', audioUrl: _ocean),
      CravingSound(emoji: '🔔', name: 'Singing Bowl', why: 'Present-moment anchor when the craving feels overwhelming.', audioUrl: _bowl),
      CravingSound(emoji: '🌲', name: 'Forest Sounds', why: 'Shifts sensory focus from the craving to the natural world.', audioUrl: _forest),
    ],
  ),
};

AddictionContent contentFor(String key) =>
    cravingContent[key] ?? cravingContent['other']!;
