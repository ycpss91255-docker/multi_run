.PHONY: test lint clean help

test: ## Run full CI (ShellCheck + Bats)
	./script/ci.sh

lint: ## Run ShellCheck only
	./script/ci.sh --lint-only

clean: ## Remove generated files
	rm -f .multi_compose.yaml .multi_state

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
