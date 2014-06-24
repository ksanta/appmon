# This function returns the t confidence interval.

# How to interpret the result: 
# The 2 numbers are the lower and upper bound 95% confidence of the difference of the means.

# Example: "-0.0027  0.0007" tells that we are 95% confident that the new k value is between 0.0027 lower or even
# 0.0007 higher.

t.confidence.interval <- function(baseline.mean, baseline.sd, baseline.count, test.mean, test.sd, test.count) {
  # Calculate pooled std.dev first
  variance.pooled = ((baseline.count - 1) * baseline.sd^2 + (test.count - 1) * test.sd^2)/(baseline.count + test.count - 2)
  std.dev.pooled = sqrt(variance.pooled)

  # Calculate t.interval value (test - baseline) and return
  df = baseline.count + test.count - 2
  interval = test.mean - baseline.mean + c(-1, 1) * qt(0.975, df) * std.dev.pooled * sqrt(1/baseline.count + 1/test.count)
  
  round(interval, 4)
}
