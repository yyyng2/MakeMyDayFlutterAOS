package io.github.yyyng2.make_my_day

import io.realm.kotlin.types.RealmObject
import io.realm.kotlin.types.annotations.PrimaryKey
import io.realm.kotlin.types.RealmInstant
import org.mongodb.kbson.ObjectId
import java.util.Date

class DdayEntity : RealmObject {
    @PrimaryKey
    var id: ObjectId = ObjectId()
    var title: String = ""
    var date: RealmInstant = RealmInstant.from(0, 0)
    var dayPlus: Boolean = false
    var repeatAnniversary: Boolean = false
    var notificationType: Int = 0
}