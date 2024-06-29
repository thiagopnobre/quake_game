# Quake Game

CloudWalk Software Engineer Test

Built in [Ruby](https://www.ruby-lang.org/).

## Getting started

There are two ways to run this project:

<details>
  <summary>Local installation</summary>

### Requirements

1. Install [ruby 3.3.3](https://gorails.com/setup/ubuntu/24.04#ruby).

#### Installation

1.  Clone the repo

    ```sh
    git clone git@github.com:thiagopnobre/quake_game.git && cd quake_game
    ```

2. Install the bundler

    ```sh
    gem install bundler
    ```

3. Install the dependencies

    ```sh
    bundle install
    ```

4. Run it

    ```sh
    ruby app.rb
    ```

</details>



<details>
  <summary>Dockerized installation</summary>

### Requirements

1. Install [docker](https://docs.docker.com/engine/install);
2. Install [docker-compose](https://docs.docker.com/compose/install/).

#### Installation

1.  Clone the repo

    ```sh
    git clone git@github.com:thiagopnobre/quake_game.git && cd quake_game
    ```

2. Run it

    ```sh
    docker-compose up
    ```

</details>



## Tests

To run the tests, execute:

  ```sh
  rspec
  ```
