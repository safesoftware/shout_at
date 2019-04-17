#!groovy

def randomUUID = UUID.randomUUID().toString()
def testLabel = "shout-at-tests-${randomUUID}"
def libCachePath = '/home/jenkins/shout-at-cache'

pipeline {
  agent {
    kubernetes {
      label testLabel
      inheritFrom 'ssd-workspace'
      yaml """
apiVersion: v1
kind: Pod
spec:
  tolerations:
  - key: safe.k8s.jenkins.component
    operator: Equal
    value: node
    effect: NoSchedule
  containers:
  - name: ruby
    image: us.gcr.io/safe-k8s-hosting/rails-base-container:2.5.3-8
    command: ['cat']
    tty: true
    resources:
      requests:
        cpu: 1
        memory: 1Gi
    env:
      - name: MALLOC_ARENA_MAX
        value: '2'
"""
    }
  }
  stages {
    stage('Prepare') {
      steps {
        container(name: 'ruby') {
          sh "mkdir -p ${libCachePath}/bundle && ln -s ${libCachePath}/bundle vendor"
          sh 'bundle install --path vendor/bundle --jobs 2'
        }
      }
    }
    stage('rspec') {
      steps {
        container(name: 'ruby') {
          script {
            sh 'bundle exec rspec spec'
          }
        }
      }
    }
    stage('release') {
      when {
        allOf {
          branch 'master'
          not {
            changelog '\\[skip ci\\]'
          }
        }
      }
      steps {
        build job: '/cai/gemfury-release',
              wait: false,
              parameters: [
                string(name: 'GIT_REPO', value: env.GIT_URL),
                string(name: 'GIT_COMMIT_HASH', value: env.GIT_COMMIT),
                string(name: 'PROJECT', value: 'shout_at'),
                string(name: 'LANGUAGE', value: 'ruby')]
      }
    }
  }
}
