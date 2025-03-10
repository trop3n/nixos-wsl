{
  # FIXME: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  pkgs,
  username,
  nix-index-database,
  ...
}: let
  unstable-packages = with pkgs.unstable; [
    # FIXME: select your core binaries that you always want on the bleeding-edge
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    binutils
    inetutils
    lsof
    gcc
    libgcc
    fx
    git
    git-crypt
    htop
    jq
    killall
    mosh
    procs
    ripgrep
    sd
    tmux
    tree
    unzip
    vim
    wget
    zip
    neofetch
    fastfetch
    gdb
    micro
    neovim
    lazygit
    zellij
#    oh-my-posh
  ];

  stable-packages = with pkgs; [
    # FIXME: customize these stable packages to your liking for the languages that you use

    # FIXME: you can add plugins, change keymaps etc using (jeezyvim.nixvimExtend {})
    # https://github.com/LGUG2Z/JeezyVim#extending
    jeezyvim
    lunarvim

    # key tools
    gh # for bootstrapping
    just
    ast-grep

    # core languages
    rustup
    ruby_3_3
    crystal_1_9
    zig
    elixir_1_16
    gleam
    go
    nodejs_18
    php
    scala
    nim


    # python stuff
    python312Full
    poetry
    python312Packages.scrapy
    python312Packages.conda

    # rust stuff
    cargo-cache
    cargo-expand

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    nil # nix

    # formatters and linters
    alejandra # nix
    deadnix # nix
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
  ];
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "24.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    # FIXME: set your preferred $SHELL
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish";
  };

  home.packages =
    stable-packages
    ++ unstable-packages
    ++
    # FIXME: you can add anything else that doesn't fit into the above two lists in here
    [
      # pkgs.some-package
      # pkgs.unstable.some-other-package
    ];

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;
 
    # FIXME: disable this if you don't want to use the starship prompt
    starship.enable = true;
    starship.settings = {
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = false;
      git_branch.style = "242";
      directory.style = "blue";
      directory.truncate_to_repo = false;
      directory.truncation_length = 8;
      python.disabled = true;
      ruby.disabled = true;
      hostname.ssh_only = false;
      hostname.style = "bold green";
    };

    # FIXME: disable whatever you don't want
    fzf.enable = true;
    fzf.enableFishIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
    zoxide.options = ["--cmd cd"];
    broot.enable = true;
    broot.enableFishIntegration = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git = {
      enable = true;
      package = pkgs.unstable.git;
      extraConfig = {
        init.defaultBranch = "main";
      };
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = "jasondkimm@proton.me";
      userName = "trop3n";
      extraConfig = {
        # FIXME: uncomment the next lines if you want to be able to clone private https repos
        # url = {
        #   "https://oauth2:${secrets.github_token}@github.com" = {
        #     insteadOf = "https://github.com";
        #   };
        #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
        #     insteadOf = "https://gitlab.com";
        #   };
        # };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };

    # FIXME: This is my fish config - you can fiddle with it if you want
    fish = {
      enable = true;
      # FIXME: run 'scoop install win32yank' on Windows, then add this line with your Windows username to the bottom of interactiveShellInit
      # fish_add_path --append /mnt/c/Users/<Your Windows Username>/scoop/apps/win32yank/0.1.1
      interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

        ${pkgs.lib.strings.fileContents (pkgs.fetchFromGitHub {
            owner = "rebelot";
            repo = "kanagawa.nvim";
            rev = "de7fb5f5de25ab45ec6039e33c80aeecc891dd92";
            sha256 = "sha256-f/CUR0vhMJ1sZgztmVTPvmsAgp0kjFov843Mabdzvqo=";
          }
          + "/extras/kanagawa.fish")}

        set -U fish_greeting
        fish_add_path --append /mnt/c/Users/JasonKimm/scoop/apps/win32yank/0.1.1/
      '';
      functions = {
        refresh = "source $HOME/.config/fish/config.fish";
        take = ''mkdir -p -- "$1" && cd -- "$1"'';
        ttake = "cd $(mktemp -d)";
        show_path = "echo $PATH | tr ' ' '\n'";
        posix-source = ''
          for i in (cat $argv)
            set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
          end
        '';
      };
      shellAbbrs =
        {
          gc = "nix-collect-garbage --delete-old";
        }
        # navigation shortcuts
        // {
          ".." = "cd ..";
          "..." = "cd ../../";
          "...." = "cd ../../../";
          "....." = "cd ../../../../";
        }
        # git shortcuts
        // {
          gapa = "git add --patch";
          grpa = "git reset --patch";
          gst = "git status";
          gdh = "git diff HEAD";
          gp = "git push";
          gph = "git push -u origin HEAD";
          gco = "git checkout";
          gcob = "git checkout -b";
          gcm = "git checkout master";
          gcd = "git checkout develop";
          gsp = "git stash push -m";
          gsa = "git stash apply stash^{/";
          gsl = "git stash list";
        };
      shellAliases = {
        jvim = "nvim";
        lvim = "lvim";
        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";
        code = "/mnt/c/Users/JasonKimm/scoop/apps/vscode/current/bin/code";
      };
      plugins = [
        {
          inherit (pkgs.fishPlugins.autopair) src;
          name = "autopair";
        }
        {
          inherit (pkgs.fishPlugins.done) src;
          name = "done";
        }
        {
          inherit (pkgs.fishPlugins.sponge) src;
          name = "sponge";
        }
      ];
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.1";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
        {
          name = "geometry";
          src = pkgs.fetchFromGitHub {
            owner = "geometry-zsh";
            repo = "geometry";
            rev = "master";
            sha256 = "02knbmcf8invkvz0g42xk3dlk4lqffk43bsmi8z4n01508jqkd8g";
          };
        }
        {
          name = "zsh-async";
          src = pkgs.fetchFromGitHub {
            owner = "mafredri";
            repo = "zsh-async";
            rev = "v1.8.6"; # Use the latest release
            sha256 = "09wlqghxczndmzpr5hgqlf90yhbbi4mh8k0179arplikgbfd75cs";
          };
        }
    ];
      oh-my-zsh = {
        enable = true;
        theme = "geometry";
        plugins = [
          "docker"
          "git"
          "git-prompt"
          "fzf"
          "flutter"
          "direnv"
          "pip"
          "poetry"
          "python"
          "rust"
          "poetry-env"
          "starship"
          "sudo"
          "zoxide"
          "nmap"
        ];
      };
/*       shellAliases = {
        k = "kubectl";
        urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
        urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
        ls = "exa --icons";
        l = "exa --icons -lh";
        ll = "exa --icons -lah";
        la = "exa --icons -A";
        lm = "exa --icons -m";
        lr = "exa --icons -R";
        lg = "exa --icons -l --group-directories-first";
        gcl = "git clone --depth 1";
        gi = "git init";
        ga = "git add";
        gc = "git commit -m";
        gp = "git push origin master";
      }; */
    };
    oh-my-posh = {
      enable = false;
      enableBashIntegration = true;
      enableFishIntegration = false;
      enableZshIntegration = false;
      useTheme = "tiwahu";
    };

    helix = {
      enable = true;
      settings = {
      theme = "monokai-pro";
        editor = {
          color-modes = true;
          completion-trigger-len = 1;
          completion-replace = true;
          cursorline = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides.render = true;
          # inline-diagnostics = {
          #   cursorline = "hint";
          #   other-lines = "error";
          # };
          lsp.display-inlay-hints = true;
          statusline.center = ["position-percentage"];
          true-color = true;
          whitespace.characters = {
            newline = "↴";
            tab = "⇥";
          };
        };
      };
    };
  };
}
