import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../theme/hyrox_theme.dart';
import '../../utils/exercise_icons.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final routine = timerState.activeRoutine;

    if (routine == null) {
      return const Scaffold(body: Center(child: Text('No workout data')));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: HyroxTheme.yellow),
                    onPressed: () {
                      ref.read(timerProvider.notifier).reset();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  Text(
                    'WORKOUT HISTORY',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: HyroxTheme.yellow,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Main Summary Card with Yellow Glow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      HyroxTheme.yellow.withOpacity(0.3),
                      HyroxTheme.yellow.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: HyroxTheme.yellow.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Routine name
                      Text(
                        routine.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Big Time Display
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatDuration(timerState.totalElapsed),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: HyroxTheme.yellow,
                                fontFeatures: [const FontFeature.tabularFigures()],
                                shadows: [
                                  Shadow(
                                    color: HyroxTheme.yellow.withOpacity(0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Stat Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'AVG HR',
                              '-- bpm',
                              Icons.favorite_border,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'TOTAL CALS',
                              '-- kcal',
                              Icons.local_fire_department_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Segments List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SEGMENTS',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  Icon(
                    Icons.expand_more,
                    color: HyroxTheme.yellow,
                    size: 20,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Segments List
              Expanded(
                child: ListView.separated(
                  itemCount: routine.exercises.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final exercise = routine.exercises[index];
                    final splitTime = index < timerState.splits.length 
                        ? timerState.splits[index] 
                        : null;
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade900,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Exercise icon with gradient
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  HyroxTheme.yellow.withOpacity(0.3),
                                  HyroxTheme.yellow.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              ExerciseIcons.getIconForExercise(exercise),
                              color: HyroxTheme.yellow,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Number indicator
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: HyroxTheme.yellow.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: HyroxTheme.yellow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Exercise name
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          
                          // Split time
                          if (splitTime != null)
                            Text(
                              _formatDuration(splitTime),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: HyroxTheme.yellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Bottom buttons
              Row(
                children: [
                  Expanded(
                    child: _buildBottomButton(
                      context,
                      'History',
                      Icons.history,
                      isYellow: true,
                      onTap: () {
                        ref.read(timerProvider.notifier).reset();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBottomButton(
                      context,
                      'Dashboard',
                     Icons.dashboard_outlined,
                      isYellow: false,
                      onTap: () {
                        ref.read(timerProvider.notifier).reset();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade900,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: HyroxTheme.yellow, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: HyroxTheme.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    String text,
    IconData icon, {
    required bool isYellow,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isYellow ? Colors.transparent : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isYellow ? HyroxTheme.yellow : Colors.grey.shade800,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isYellow ? HyroxTheme.yellow : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isYellow ? HyroxTheme.yellow : Colors.white,
                    letterSpacing: 1.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
