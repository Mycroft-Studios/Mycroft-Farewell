import { createTheme, ThemeProvider } from '@mui/material';
import React from 'react';
import { ReactNode } from 'react';
import { themes } from './app.theme';

interface ThemeSwitchProviderProps {
  mode: 'light' | 'dark';
  children: ReactNode;
}
const ThemeSwitchProvider = ({ children, mode }: ThemeSwitchProviderProps) => {
  const themeOptions = themes[mode];
  const theme = createTheme(themeOptions);

  return <ThemeProvider theme={theme}>{children}</ThemeProvider>;
};

export default ThemeSwitchProvider;
