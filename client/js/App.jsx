import React from 'react';
import ReactDOM from 'react-dom';
import { ConnectedRouter } from 'react-router-redux';
import { ApolloProvider } from 'react-apollo';
import { store, history } from './app/store';
import client from './app/client';
import Routing from './Routing';
import '../css/app.scss';
import 'bootstrap';
import 'react-select/dist/react-select.css';

const App = () => {
  return (
    <ApolloProvider client={client} store={store}>
      <ConnectedRouter dispatch={store.dispatch} history={history}>
        <Routing store={store}/>
      </ConnectedRouter>
    </ApolloProvider>
  );
}

ReactDOM.render(
  <App/>,
  document.getElementById('app')
);
