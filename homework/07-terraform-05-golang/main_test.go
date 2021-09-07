package main
import (
	"testing"
	"reflect"
)

func TestMtoF(t *testing.T)  {
	v := MtoF(30.48)
	if v != 100 {
		t.Error("Expected 100, got ", v)
	}
}

func TestMin(t *testing.T)  {
	v := Min([]int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,})
	if v != 9 {
		t.Error("Expected 9, got ", v)
	}
}

func TestDelThree(t *testing.T)  {
	v := DelThree(1, 50)
	w := []int{3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48}
	if reflect.DeepEqual(v, w) == false {
		t.Error("Expected ", w, ",\n got ", v)
	}
}