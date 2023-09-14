package token

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const MinSecretKeySize = 32

// JWTMaker is a JSON Web Token maker.
type JWTMaker struct {
	secretKey string
}

func (maker JWTMaker) CreateToken(username string, duration time.Duration) (string, error) {
	payload, err := NewPayload(username, duration)
	if err != nil {
		return "", fmt.Errorf("cannot create PaylLoad :%w", err)
	}

	jwtToken := jwt.NewWithClaims(jwt.SigningMethodHS256, payload)

	return jwtToken.SignedString([]byte(maker.secretKey))
}

func (maker JWTMaker) VerifyToken(token string) (*Payload, error) {
	keyFunc := func(token *jwt.Token) (interface{}, error) {
		_, ok := token.Method.(*jwt.SigningMethodHMAC)
		if !ok {
			return nil, ErrInvalidToken
		}
		return []byte(maker.secretKey), nil
	}

	jwtToken, err := jwt.ParseWithClaims(token, &Payload{}, keyFunc)
	if err != nil {
		// TODO check if we really need that.
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrExpiredToken
		}

		return nil, err
	}

	payload, ok := jwtToken.Claims.(*Payload)
	if !ok {
		return nil, ErrInvalidToken
	}

	return payload, nil
}

// NewJWTMaker creates a new JWTMaker.
func NewJWTMaker(secretKey string) (Maker, error) {
	if len(secretKey) < MinSecretKeySize {
		return nil, fmt.Errorf("invalid key size: must be at least %d characters", MinSecretKeySize)
	}

	return &JWTMaker{secretKey: secretKey}, nil
}
