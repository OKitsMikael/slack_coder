import React, { Component } from 'react';
import SynchronizePRLink from './SynchronizePRLink';

export default class PRRow extends Component {
  statusClass(status) {
    switch(status) {
      case 'FAILURE':
      case 'ERROR':
        return 'danger';
      case 'SUCCESS':
        return 'success';
      case 'PENDING':
        return 'warning';
      case 'CONFLICT':
        return 'highlight';
      default:
        return 'info';
    }
  }

  componentDidMount() {
    let { type, pr, subscribe } = this.props;
    this.unsubscribe = subscribe(pr, type);
  }

  componentWillUnmount() {
    this.unsubscribe();
  }

  render() {
    const { pr, synchronize } = this.props;
    return (
      <div className="col-xs-12 pull-request-row">
        <div className="row">
          <div className="hidden-xs">
            <div className="col-sm-1">
              <img src={pr.user && pr.user.avatarUrl} className="img-circle user-avatar" />
            </div>
            <div className="col-sm-2 hidden-xs">
              {pr.user && pr.user.name}
              <br/>
              <a href={`https://github.com/${pr.owner}/${pr.repository}/`}>{pr.repository}</a>
            </div>
            <div className="col-sm-2 branch-container">
              {pr.branch}
            </div>
            <div className="col-sm-5">
              <a href={pr.htmlUrl} target="_blank">{pr.title}</a>
            </div>
            <div className="col-sm-1">
              <a href={pr.buildUrl} className={`label label-${this.statusClass(pr.buildStatus)} text-uppercase`} target="_blank" data-placement='top' data-toggle="tooltip" title="Current Status">
                {pr.buildStatus || 'Unknown'}
              </a>
            </div>
            <div className="col-sm-1">
              <span className="codeclimate-container">
                {pr.analysisUrl && (
                  <a href={pr.analysisUrl} target="_blank" data-placement="top" data-toggle="tooltip" title="CodeClimate">
                    <i className='code-climate'></i>
                  </a>
                )}
              </span>
              <SynchronizePRLink owner={pr.owner} repository={pr.repository} number={pr.number} />
            </div>
          </div>
        {/* <div className="col-md-4">
          <span><img src={pr.user && pr.user.avatarUrl} className="img-circle user-avatar" /></span>
          <span className="hidden-xs">
            {pr.user && pr.user.github}
          </span>
        </div> */}
        {/* <div className="hidden-xs">
          <a href={`https://github.com/${pr.owner}/${pr.repository}/`}>{pr.repository}</a>
        </div>
        <div className="hidden-xs hidden-sm hidden-md">
          {pr.branch}
        </div>
        <div>
          <a href={pr.htmlUrl} target="_blank">{pr.title}</a>
        </div>
        <div>
          <a href={pr.buildUrl} className={`label label-${this.statusClass(pr.buildStatus)} text-uppercase`} target="_blank" data-placement='top' data-toggle="tooltip" title="Current Status">
            {pr.buildStatus || 'Unknown'}
          </a>
        </div>
        <div className="hidden-xs">
          {pr.analysisUrl && (
            <a href={pr.analysisUrl} target="_blank" data-placement="top" data-toggle="tooltip" title="CodeClimate">
              <i className='code-climate'></i>
            </a>
          )}
        </div>
        <div>
          <SynchronizePRLink owner={pr.owner} repository={pr.repository} number={pr.number} />
        </div> */}
        </div>
      </div>
    );
  }
}
