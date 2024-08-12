import 'package:hive/hive.dart';
import 'package:ecosmart/models/activity_model.dart';

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 0;

  @override
  Activity read(BinaryReader reader) {
    return Activity(
      id: reader.readString(),
      userId: reader.readString(),
      category: reader.readString(),
      description: reader.readString(),
      quantity: reader.readDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      recommendation: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeString(obj.category);
    writer.writeString(obj.description);
    writer.writeDouble(obj.quantity);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.recommendation ?? '');
  }
}
