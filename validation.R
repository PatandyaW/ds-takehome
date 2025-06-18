head(df_predictions)

library(glmtoolbox)

X <- df_predictions[, c("logreg_preds", "gb_preds")]  
y <- df_predictions$true  


logreg_model <- glm(y ~ logreg_preds + gb_preds, family = binomial, data = df_predictions)


summary(logreg_model)

hl_test_logreg <- hltest(logreg_model, X = df_predictions$logreg_preds, y = df_predictions$true)
hl_test_gb <- hltest(logreg_model, X = df_predictions$gb_preds, y = df_predictions$true)


print(hl_test_logreg)
print(hl_test_gb)

library(ggplot2)
logreg_plot <- ggplot(df_predictions, aes(x = logreg_preds, y = true)) +
  geom_point(alpha = 0.5) +  
  geom_smooth(method = "loess", color = "blue") +  
  labs(title = "Calibration Curve - Logistic Regression",
       x = "Predicted Probability",
       y = "Observed Probability") +
  theme_minimal()


ggsave("calibration_curve_logreg.png", plot = logreg_plot)

gb_plot <- ggplot(df_predictions, aes(x = gb_preds, y = true)) +
  geom_point(alpha = 0.5) +  
  geom_smooth(method = "loess", color = "green") +  
  labs(title = "Calibration Curve - Gradient Boosting",
       x = "Predicted Probability",
       y = "Observed Probability") +
  theme_minimal()


ggsave("calibration_curve_gb.png", plot = gb_plot)
getwd()

cut_off_logreg <- quantile(df_predictions$logreg_preds, probs = 0.05)
cut_off_gb <- quantile(df_predictions$gb_preds, probs = 0.05)


print(paste("Cut-off untuk expected default ≤ 5% - Logistic Regression: ", cut_off_logreg))
print(paste("Cut-off untuk expected default ≤ 5% - Gradient Boosting: ", cut_off_gb))


cat(paste("### Cut-off Score untuk Expected Default ≤ 5%\n\n",
          "Cut-off score untuk prediksi default dengan probabilitas ≤ 5% adalah:\n",
          "- Logistic Regression: ", cut_off_logreg, "\n",
          "- Gradient Boosting: ", cut_off_gb, "\n"), 
    file = "C_summary.md")
