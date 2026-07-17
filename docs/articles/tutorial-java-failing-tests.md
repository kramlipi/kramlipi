---
title: Fix Failing Java Tests Until Maven Builds Green
description: >-
  Create a JUnit failure in a Maven project, fix App.add with Kramlipi code-agent
  using mvn test -q as verify-cmd — plus a short Gradle path.
keywords: >-
  java junit maven tutorial, failing unit test, mvn test verify-cmd, gradle test,
  code-agent bug-fix, Kramlipi AI Code Agent
---

# Fix Failing Java Tests Until Maven Builds Green

The Slack message says “BUILD SUCCESS.” Your laptop says otherwise:

```text
[ERROR] Failures:
[ERROR]   AppTest.testAdd:15 expected:<5> but was:<-1>
[INFO] BUILD FAILURE
```

JUnit caught it. Maven stopped the world. You know the fix is probably one operator in `App.java` — but between downloading dependencies, re-running Surefire, and waiting for CI, a one-line bug eats an hour.

**Kramlipi AI Code Agent** closes that loop. It edits your repo with tools and **only stops when `--verify-cmd` exits 0**. It does not invent success. If `mvn test` still reports `BUILD FAILURE`, the agent keeps working or fails honestly.

This tutorial builds a Maven quickstart under `/tmp/java-demo`, breaks `App.add`, and fixes it two ways: prompt mode and `bug-fix --log`.

---

## What you need

| Item | Notes |
|------|-------|
| JDK 17+ | `java -version` and `mvn -version` must work |
| Maven | For the primary walkthrough below |
| `code-agent` binary | [GitHub Releases](https://github.com/kramlipi/code-agent-binaries/releases) |
| API key | Gemini, Claude, or OpenAI |

```bash
chmod +x code-agent
export CODE_AGENT_MODEL=gemini/gemini-2.0-flash
export GEMINI_API_KEY=your-key-here

./code-agent doctor --provider-test
```

Claude and OpenAI work the same way — set `CODE_AGENT_MODEL` to an `anthropic/…` or `openai/…` string and export the matching key.

---

## Step 1 — Create a failing Maven + JUnit test

```bash
mkdir -p /tmp/java-demo && cd /tmp/java-demo
git init

mvn archetype:generate -DgroupId=com.example -DartifactId=demo \
  -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false

cd demo

cat > src/main/java/com/example/App.java <<'EOF'
package com.example;

public class App {
    public static int add(int a, int b) {
        return a - b; // BUG: should be +
    }
}
EOF

cat > src/test/java/com/example/AppTest.java <<'EOF'
package com.example;

import org.junit.Test;
import static org.junit.Assert.*;

public class AppTest {
    @Test
    public void testAdd() {
        assertEquals(5, App.add(2, 3));
    }
}
EOF

mvn test
```

Expected: `BUILD FAILURE` with an assertion error in Surefire output.

Save the log:

```bash
mvn test 2>&1 | tee /tmp/java-maven.log
```

!!! info "Parser note"
    Java/JUnit log parsing is more generic than pytest's — the agent leans on Surefire output **plus** re-running your verify command. That makes `--verify-cmd "mvn test -q"` critical: the subprocess is the final judge.

---

## Step 2 — Fix with `code-agent run`

Point `-w` at the Maven module root — the folder containing `pom.xml`.

```bash
code-agent run \
  "Fix failing AppTest. The add method in App.java returns the wrong result. Run 'mvn test -q' until BUILD SUCCESS. Change only what is needed." \
  --verify-cmd "mvn test -q" \
  -w /tmp/java-demo/demo
```

### Inside the loop

1. Agent reads `src/main/java/com/example/App.java` and the test.
2. Agent patches production code via file tools — not chat-only suggestions.
3. Agent runs `mvn test -q`.
4. Exit 0 → done. Non-zero → iterate.

**No green Maven build, no done.** That is the core rule.

On success:

```text
Status: done
Files: src/main/java/com/example/App.java
```

Verify:

```bash
cd /tmp/java-demo/demo && mvn test -q
# BUILD SUCCESS
```

### Flags explained

| Flag | Value | Meaning |
|------|-------|---------|
| `-w` | `/tmp/java-demo/demo` | Maven module root (`pom.xml` lives here) |
| `--verify-cmd` | `mvn test -q` | Quiet test run — match what CI uses |
| Task string | Plain English | What to fix and how to prove it |

If CI runs `mvn verify` or `./mvnw test`, use **that exact command** in `--verify-cmd`.

---

## Step 3 — Fix with `bug-fix` expert (CI log mode)

When Jenkins or GitHub Actions already failed and you have the log:

```bash
cd /tmp/java-demo/demo
mvn test 2>&1 | tee /tmp/java-maven.log

code-agent experts run bug-fix \
  --log /tmp/java-maven.log \
  --verify-cmd "mvn test -q" \
  -w /tmp/java-demo/demo
```

| Flag | Why |
|------|-----|
| `--log` | Surefire failure lines become structured intake |
| `--verify-cmd "mvn test -q"` | Same proof bar as prompt mode |
| `-w` | Limits edits to `src/main` and `src/test` under this module |

Optional workflow flags:

- `--dry-run` — plan without pushing
- `--publish` — commit fix, push branch, open draft PR (`gh auth login` required)

---

## Gradle — short path

Gradle projects follow the same rules with different verify commands.

```bash
mkdir -p /tmp/gradle-demo && cd /tmp/gradle-demo
git init

gradle init --type java-application --dsl kotlin \
  --test-framework junit-jupiter --package com.example --project-name demo

cd demo
# Introduce the same a - b bug in your App class, then:
./gradlew test 2>&1 | tee /tmp/java-gradle.log

code-agent experts run bug-fix \
  --log /tmp/java-gradle.log \
  --verify-cmd "./gradlew test" \
  -w /tmp/gradle-demo/demo
```

| Build tool | Typical `--verify-cmd` |
|------------|------------------------|
| Maven | `mvn test -q` |
| Gradle | `./gradlew test` |

Pick **one** tool per project. Do not mix Maven flags with a Gradle repo.

---

## CI integration pattern

```bash
mvn test -q 2>&1 | tee /tmp/ci.log

code-agent experts run bug-fix \
  --log /tmp/ci.log \
  --verify-cmd "mvn test -q" \
  -w "$GITHUB_WORKSPACE"
```

Your pipeline still owns credentials, JDK setup, and artifact caching. The agent owns the edit-until-green loop.

For PRs that keep failing after pushes:

```bash
code-agent experts watch \
  --pr 42 \
  --verify-cmd "mvn test -q" \
  -w /path/to/java-project
```

---

## Common mistakes

| Mistake | Result | Fix |
|---------|--------|-----|
| `-w` at parent of `pom.xml` | Agent cannot find sources | `-w` = folder containing `pom.xml` |
| `mvn test` vs `mvn verify` in CI | Local fix, CI still red | Copy CI's exact lifecycle command |
| JDK not installed | Verify never runs | Install JDK 17+; check `java -version` |
| Mixing Maven and Gradle verify | Wrong build tool invoked | One verify command, one build system |
| Trusting “BUILD SUCCESS” in chat | Tests still fail | Only `--verify-cmd` exit 0 counts |
| Skipping `-q` when CI uses `-q` | Different output, drift | Match CI flags exactly |

---

## What you learned

- Maven proof = `mvn test -q` (or your CI's equivalent).
- `-w` scopes to the module; `--verify-cmd` scopes success.
- Gradle uses `./gradlew test` — same loop, different gate.
- The agent edits with tools and stops only on verify exit 0.

**Next:** [Quick Start](https://kramlipi.github.io/quick-start/) · [Java examples](../examples/java.md) · [Coverage tutorial](tutorial-raise-coverage.md) · Questions: [cluevion@gmail.com](mailto:cluevion@gmail.com)
