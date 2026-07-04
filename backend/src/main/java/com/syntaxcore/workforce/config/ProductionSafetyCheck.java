package com.syntaxcore.workforce.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Refuses to start the "prod" profile if critical secrets were left at their
 * insecure development defaults. Without this check, deploying without
 * setting JWT_SECRET (for example) would start up completely normally —
 * no error, no warning — while every issued token is signed with a secret
 * that's checked into source control and known to anyone who has read this
 * codebase. That's a silent, critical vulnerability precisely because
 * nothing fails: this makes it fail loudly instead, at startup, before it
 * can ever accept traffic.
 */
@Component
@Profile("prod")
@Slf4j
public class ProductionSafetyCheck implements ApplicationRunner {

    private static final String DEFAULT_JWT_SECRET =
        "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${spring.datasource.password}")
    private String dbPassword;

    @Override
    public void run(ApplicationArguments args) {
        StringBuilder problems = new StringBuilder();

        if (DEFAULT_JWT_SECRET.equals(jwtSecret)) {
            problems.append("\n  - JWT_SECRET is still the default value from application.yml. ")
                    .append("Set a unique, random 64+ character JWT_SECRET env var.");
        }
        if (jwtSecret == null || jwtSecret.length() < 32) {
            problems.append("\n  - JWT_SECRET is too short (< 32 chars) to be a safe signing key.");
        }
        if ("postgres".equals(dbPassword)) {
            problems.append("\n  - DB_PASSWORD is still the default 'postgres'. Set a real DB_PASSWORD env var.");
        }

        if (problems.length() > 0) {
            String message = "Refusing to start with the 'prod' profile due to insecure configuration:"
                + problems + "\n\nSet the missing environment variables and restart.";
            log.error(message);
            throw new IllegalStateException(message);
        }
    }
}
