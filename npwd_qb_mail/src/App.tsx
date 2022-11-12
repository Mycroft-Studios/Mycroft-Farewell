import React from 'react';
import { NuiProvider } from 'react-fivem-hooks';
import styled from 'styled-components';
import { IPhoneSettings } from '@project-error/npwd-types';
import { i18n } from 'i18next';
import { Theme, StyledEngineProvider, ThemeProvider, Typography, Box } from '@mui/material';
import MailList from './components/MailList';
import { RecoilRoot } from 'recoil';
import MailModal from './components/MailModal';
import Header from './components/Header';
import { PhoneSnackbar } from './snackbar/PhoneSnackbar';
import SnackbarProvider from './snackbar/SnackbarProvider';

const Container = styled.div<{ isDarkMode: any }>`
  flex: 1;
  display: flex;
  box-sizing: border-box;
  flex-direction: column;
  overflow: auto;
  max-height: 100%;
  background-color: #fafafa;
  ${({ isDarkMode }) =>
    isDarkMode &&
    `
    background-color: #212121;
  `}
`;
interface AppProps {
  theme: Theme;
  i18n: i18n;
  settings: IPhoneSettings;
}

const App = (props: AppProps) => {
  const isDarkMode = props.theme.palette.mode === 'dark';

  return (
    <RecoilRoot>
      <SnackbarProvider>
        <StyledEngineProvider injectFirst>
          <ThemeProvider theme={props.theme}>
            <PhoneSnackbar />
            <Container isDarkMode={isDarkMode}>
              <Header />
              <MailModal />
              <MailList isDarkMode={isDarkMode} />
            </Container>
          </ThemeProvider>
        </StyledEngineProvider>
      </SnackbarProvider>
    </RecoilRoot>
  );
};

const WithProviders: React.FC<AppProps> = (props) => (
  <NuiProvider>
    <App {...props} />
  </NuiProvider>
);

export default WithProviders;
