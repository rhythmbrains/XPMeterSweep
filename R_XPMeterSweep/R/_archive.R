

# this is an old version of 8_12 synpy sequences
# 
# #===========================================================================================
# #-------------------------- analysis of continuous sequences LHL using synpy ---------------
# #===========================================================================================
# 
# sequences <- read.csv('/Users/tomaslenc/Dropbox/Tomas_PhD/XPSyncSweep/stimuli/3-beat-patterns/out/continuous/XPSyncSweep_continuous.csv')
# 
# # library(stringr)
# # str_extract(sequences$filename, '^(trial\\d?\\d)')
# sequences$trial <- regmatches(sequences$filename, regexpr('^(trial\\d?\\d)',sequences$filename))
# sequences$beatcycle <- regmatches(sequences$filename, regexpr('\\dbeatcycle',sequences$filename))
# 
# sequences$direction <- regmatches(sequences$filename, regexpr('(high2low)|(low2high)',sequences$filename))
# sequences$direction <- factor(sequences$direction, levels=c("low2high","high2low"))
# 
# sequences$section <- regmatches(sequences$filename, regexpr('\\d.rhy',sequences$filename))
# sequences$section <- (substr(sequences$section,1,1))
# 
# # reverse the section order for high2low
# sequences$sectionrev <- sequences$section
# sequences[sequences$direction=="high2low"&sequences$section==3,"sectionrev"]=1
# sequences[sequences$direction=="high2low"&sequences$section==1,"sectionrev"]=3
# 
# 
# #------------------------------ assuming 3-beat cycle ---------------------------------------
# # plot 
# pos <- position_dodge(0.1)
# df2plot <- subset(sequences,beatcycle=="3beatcycle")
# ggplot(df2plot, aes(direction,mean_sync_per_bar,group=paste(sectionrev,trial),color=sectionrev)) + 
#   geom_point(position = pos) + 
#   geom_line(position=pos) + 
#   theme_bw() + 
#   ggtitle("Assumed 3-beat cycle") + 
#   theme(
#     title = element_text(size=16, color="black"), 
#     axis.text = element_text(size=16, color="black"), 
#     axis.title = element_text(size=16, color="black"), 
#     legend.text = element_text(size=16, color="black"), 
#     legend.title = element_text(size=16, color="black"), 
#     panel.border = element_blank(), 
#     axis.line = element_line()
#   )
# 
# 
# 
# #------------------------------ assuming 2-beat cycle ---------------------------------------
# # plot 
# pos <- position_dodge(0.1)
# df2plot <- subset(sequences,beatcycle=="2beatcycle")
# ggplot(df2plot, aes(direction,mean_sync_per_bar,group=paste(sectionrev,trial),color=sectionrev)) + 
#   geom_point(position = pos) + 
#   geom_line(position=pos) + 
#   theme_bw() + 
#   ggtitle("Assumed 2-beat cycle") + 
#   theme(
#     title = element_text(size=16, color="black"), 
#     axis.text = element_text(size=16, color="black"), 
#     axis.title = element_text(size=16, color="black"), 
#     legend.text = element_text(size=16, color="black"), 
#     legend.title = element_text(size=16, color="black"), 
#     panel.border = element_blank(), 
#     axis.line = element_line()
#   )
# 
# 
# 
# 
# # test for significant difference between the original and reversed stimulus
# m1 <- lmer(mean_sync_per_bar ~ direction + sectionrev + (1|trial), data=subset(sequences,beatcycle=="2beatcycle"))
# m2 <- lmer(mean_sync_per_bar ~ direction * sectionrev + (1|trial), data=subset(sequences,beatcycle=="2beatcycle"))
# 
# KRmodcomp(m1,m2)
# Anova(m2, test="F")
# 
# visreg(m2, xvar="sectionrev", by="direction", overlay=T)
# 
# m3 <- lmer(mean_sync_per_bar ~ sectionrev + sectionrev:direction -1 + (1|trial), data=subset(sequences,beatcycle=="2beatcycle"))
# 
# summary(m3)
# summary(glht(m3,linfct=c('sectionrev1:directionhigh2low == 0', 
#                          'sectionrev2:directionhigh2low == 0', 
#                          'sectionrev3:directionhigh2low == 0')))
# 
# 
# plot(m2)
# qqPlot(residuals(m2))
# 
# 
# 
# 



















#===========================================================================================
#-------------------------- z beat ---------------------------------------------------------
#===========================================================================================
# 
# # plot 
# ggplot(df_all, aes(sum_syncop, z_beat)) + 
#   geom_point() + 
#   facet_grid(rampoff~dutycycle+rampon,labeller="label_both",scales="free") + 
#   theme_bw()
# 
# 
# ggplot(df_all, aes(range_syncop, z_beat)) + 
#   geom_point() + 
#   facet_grid(rampoff~dutycycle+rampon,labeller="label_both",scales="free") + 
#   theme_bw() 
# 
# 
# # fit model
# 
# zbeatfit1 <- lm(z_beat ~ sum_syncop*range_syncop*rampon*dutycycle*rampoff, data=df_all)
# zbeatfit2 <- lm(log10(z_beat-min(z_beat)+1) ~ sum_syncop*rampon*dutycycle*rampoff, data=df_all)
# zbeatfit3 <- lm(z_beat ~ sum_syncop*range_syncop*(rampon+dutycycle+rampoff), data=df_all)
# 
# summary(zbeatfit1)
# Anova(zbeatfit1)
# 
# residualPlot(zbeatfit1)
# qqPlot(zbeatfit1)
# 
# visreg(zbeatfit1, xvar="sum_syncop", by="range_syncop", overlay=T, band=F)
# 
#===========================================================================================
#-------------------------- z meter --------------------------------------------------------
#===========================================================================================
# 
# ggplot(df_all, aes(sum_syncop, z_meter)) + 
#   geom_point() + 
#   facet_grid(rampoff~dutycycle+rampon,labeller="label_both",scales="free") + 
#   theme_bw()
# 
# ggplot(df_all, aes(range_syncop, z_meter)) + 
#   geom_point() + 
#   facet_grid(rampoff~dutycycle+rampon,labeller="label_both",scales="free") + 
#   theme_bw()
# 
# 
# zmeterfit1 <- lm(z_meter ~ sum_syncop*range_syncop*rampon*dutycycle*rampoff, data=df_all)
# 
# Anova(zmeterfit1)
# 
# visreg(zbeatfit1, xvar="range_syncop", by="dutycycle", overlay=T, band=F)
# 
# 




# 
# 
# 
# #======================== take subsets of data to see WTF is going on ======================================================================================
# 
# 
# #---------subset only with varying duty cycle------------------------------------
# df_duty <- subset(df_all, rampon==0.01&rampoff==0.05)
# 
# zmeterfit1 <- lm(z_meter ~ range_syncop+dutycycle, data=df_duty)
# zmeterfit2 <- lm(z_meter ~ range_syncop*dutycycle, data=df_duty)
# 
# anova(zmeterfit1,zmeterfit2)
# AIC(zmeterfit1,zmeterfit2)
# 
# summary(zmeterfit2)
# Anova(zmeterfit2)
# visreg(zmeterfit2, xvar="range_syncop", by="dutycycle", overlay=T)
# 
# # we can do separate correlations, it's strong as a pig...
# cor.test(unlist(subset(df_duty, dutycycle==0.07, select = z_meter)), unlist(subset(df_duty, dutycycle==0.07, select = range_syncop)))
# cor.test(unlist(subset(df_duty, dutycycle==0.2, select = z_meter)), unlist(subset(df_duty, dutycycle==0.2, select = range_syncop)))
# 
# 
# 
# 
# #---------subset only with varying rampon------------------------------------
# df_onset <- subset(df_all, rampon%in%c(0.01,0.005)&rampoff==0.05&dutycycle==0.2)
# 
# zmeterfit1 <- lm(z_meter ~ range_syncop+rampon, data=df_onset)
# zmeterfit2 <- lm(z_meter ~ range_syncop*rampon, data=df_onset)
# 
# anova(zmeterfit1,zmeterfit2)
# AIC(zmeterfit1,zmeterfit2)
# 
# summary(zmeterfit1)
# Anova(zmeterfit1)
# visreg(zmeterfit1, xvar="range_syncop", by="rampon", overlay=T)
# 
# residualPlot(zmeterfit2)
# qqPlot(zmeterfit2)
# 
# #---------subset only with varying rampoff------------------------------------
# df_offset <- subset(df_all, rampoff%in%c(0.01,0.05)&rampon==0.01&dutycycle==0.2)
# 
# zmeterfit1 <- lm(z_meter ~ range_syncop+rampoff, data=df_offset)
# zmeterfit2 <- lm(z_meter ~ range_syncop*rampoff, data=df_offset)
# 
# anova(zmeterfit1,zmeterfit2)
# AIC(zmeterfit1,zmeterfit2)
# 
# summary(zmeterfit1)
# Anova(zmeterfit1)
# visreg(zmeterfit1, xvar="range_syncop", by="rampoff", overlay=T)
# 
# 
# 
# 
#


