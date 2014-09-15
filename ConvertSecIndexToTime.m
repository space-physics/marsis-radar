function [hour, minute, sec] = ConvertSecIndexToTime(secIndex)
hour = floor(secIndex/3600);
secIndex = secIndex - hour*3600;

minute = floor(secIndex/60);
sec = secIndex-minute*60;

