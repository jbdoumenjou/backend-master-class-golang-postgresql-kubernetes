package db

import (
	"database/sql"
	"fmt"
	"github.com/jbdoumenjou/simplebank/util"
	"log"
	"os"
	"testing"

	_ "github.com/lib/pq"
)

var testQueries *Queries
var testDB *sql.DB

func TestMain(m *testing.M) {
	var err error
	fmt.Println("Initializing test suite")

	config, err := util.LoadConfig("../..")
	if err != nil {
		log.Fatal("cannot load configuration:", err)
	}
	testDB, err = sql.Open(config.DBDriver, config.DBSource)
	if err != nil {
		log.Fatal("cannot connect to the db:", err)
	}
	testQueries = New(testDB)

	os.Exit(m.Run())
}
