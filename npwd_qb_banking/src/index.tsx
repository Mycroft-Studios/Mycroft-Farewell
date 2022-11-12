/*
    NOTICE

    This is not used in production.
    Anything you put here will NOT get loaded into NPWD.
*/

import React from 'react';
import ReactDOM from 'react-dom';
import '../npwd.config';

import { HashRouter } from 'react-router-dom';
import styled from 'styled-components';
import App from './App';
import image from './bg.png';
import { NuiProvider } from 'react-fivem-hooks';
import { RecoilRoot } from 'recoil';
import { IPhoneSettings } from '@project-error/npwd-types';
import i18next from 'i18next';
import { createTheme } from '@mui/material';

const Container = styled.div`
  position: relative;
  width: 500px;
  height: 1000px;
`;
const Background = styled.div<{ src: string }>`
  background: url(${({ src }) => src});
  position: absolute;
  z-index: 100;
  width: 500px;
  height: 1000px;
  pointer-events: none;
`;

const AppContainer = styled.div`
  z-index: 2;
  position: absolute;
  bottom: 100px;
  left: 50px;
  right: 50px;
  top: 100px;
  display: flex;
  flex-direction: column;
  background-position: center;
  background-size: cover;
  background-repeat: no-repeat;
  border-radius: 20px;
  overflow: hidden;
`;

// Default settings will come from package. This is for development purposes.
const settings = {
  language: {
    label: 'English',
    value: 'en',
  },
  theme: {
    label: 'Theme name',
    value: 'theme-name',
  },
} as IPhoneSettings;

const theme = createTheme({
  palette: {
    mode: 'light',
  },
});

/*
 *   Providers loaded here will only be applied to the development environment.
 *   If you want to add more providers to the actual app inside NPWD you have to add them in APP.tsx.
 */

const Root = () => {
  if (process.env.REACT_APP_IN_GAME) {
    return null;
  }

  return (
    <HashRouter>
      <RecoilRoot>
        <NuiProvider>
          <Container>
            <Background src={image} />
            <AppContainer>
              <App settings={settings} i18n={i18next} theme={theme} />
            </AppContainer>
          </Container>
        </NuiProvider>
      </RecoilRoot>
    </HashRouter>
  );
};

ReactDOM.render(<Root />, document.getElementById('root'));
